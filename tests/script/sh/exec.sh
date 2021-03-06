#!/bin/sh

# if [ $# != 4 || $# != 5 ]; then 
  # echo "argument list need input : "
  # echo "  -n nodeName"
  # echo "  -s start/stop"
  # echo "  -c clear"
  # exit 1
# fi

NODE_NAME=
EXEC_OPTON=
CLEAR_OPTION="false"
while getopts "n:s:u:x:ct" arg 
do
  case $arg in
    n)
      NODE_NAME=$OPTARG
      ;;
    s)
      EXEC_OPTON=$OPTARG
      ;;
    c)
      CLEAR_OPTION="clear"
      ;;
    t)
      SHELL_OPTION="true"
      ;;
    u)
      USERS=$OPTARG
      ;;
    x)
      SIGNAL=$OPTARG
      ;;
    ?)
      echo "unkown argument"
      ;;
  esac
done

SCRIPT_DIR=`dirname $0`
cd $SCRIPT_DIR/../
SCRIPT_DIR=`pwd`

cd ../../
TAOS_DIR=`pwd`

BUILD_DIR=$TAOS_DIR/debug/build
SIM_DIR=$TAOS_DIR/sim
NODE_DIR=$SIM_DIR/$NODE_NAME
EXE_DIR=$BUILD_DIR/bin
CFG_DIR=$NODE_DIR/cfg
LOG_DIR=$NODE_DIR/log
DATA_DIR=$NODE_DIR/data
MGMT_DIR=$NODE_DIR/data/mgmt
TSDB_DIR=$NODE_DIR/data/tsdb

TAOS_CFG=$NODE_DIR/cfg/taos.cfg

echo ------------ $EXEC_OPTON $NODE_NAME

TAOS_FLAG=$SIM_DIR/tsim/flag
if [ -f "$TAOS_FLAG" ]; then 
  EXE_DIR=/usr/local/bin/taos
fi

if [ "$CLEAR_OPTION" = "clear" ]; then 
  echo rm -rf $MGMT_DIR $TSDB_DIR  
  rm -rf $TSDB_DIR
  rm -rf $MGMT_DIR
fi

if [ "$EXEC_OPTON" = "start" ]; then 
  echo "ExcuteCmd:" $EXE_DIR/taosd -c $CFG_DIR
  
  if [ "$SHELL_OPTION" = "true" ]; then 
    nohup valgrind --log-file=${LOG_DIR}/valgrind.log --tool=memcheck --leak-check=full --show-reachable=no  --track-origins=yes --show-leak-kinds=all  -v  --workaround-gcc296-bugs=yes   $EXE_DIR/taosd -c $CFG_DIR > /dev/null 2>&1 &   
  else
    nohup $EXE_DIR/taosd -c $CFG_DIR > /dev/null 2>&1 & 
  fi
  
else
  #relative path
  RCFG_DIR=sim/$NODE_NAME/cfg
  PID=`ps -ef|grep taosd | grep $RCFG_DIR | grep -v grep | awk '{print $2}'`
  if [ -n "$PID" ]; then 
    if [ "$SIGNAL" = "SIGINT" ]; then 
      echo killed by signal
      sudo kill -sigint $PID
    else
      sudo kill -9 $PID
    fi
  fi 
fi

