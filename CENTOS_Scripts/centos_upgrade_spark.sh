#==Point Spark to Python ==============================================================
#!/usr/bin/env bash
cd /tmp

#update bin link python to python2 & python3
    #ln -sf $PYTHON_HOME /usr/local/bin/python3.6

#Update PySpark Version
    #PYSPARK_PYTHON=/usr/local/bin/python3.6
echo "PYSPARK_PYTHON=\"${PYTHON_HOME}/python\"" >> /etc/environment
echo "PYSPARK_DRIVER_PYTHON=\"${PYTHON_HOME}/python\"" >> /etc/environment

exit 0