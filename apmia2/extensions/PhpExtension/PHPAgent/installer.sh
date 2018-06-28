#!/bin/bash
# chkconfig: 2345 92 18
# description: CA APM PHP Probe Agent Installer
########################################################################

usage() {
  echo ""
  echo "${bold}  Interactive install Usage: ./installer.sh -i ${rmso}"
  quickInstallUsage 
}

quickInstallUsage() {
  echo ""
  echo "${bold}  Quick install Usage: ./installer.sh -appname <PHP app name> -iahost <Infrastructure agent host/IP addr> -iaport <Infrastructure agent port> -phproot <php root directory> 
                                      -ext <php extension directory> -ini <php ini directory> -logdir <probe agent logs directory> "
  cat <<EOF
  where
       appname                - Sets the name of the Frontend application under which metrics will be reported.It is highly recommended to set an application name.Default value is "PHP App"
       
       iahost               - Hostname/IP address of remote machine on which Infrastructure agent is running and listening for Probe agents. 
                                (If Infrastructure agent is running on the same machine as Probe agent this param can be ignored.)

       iaport               - Port on which Infrastructure agent is listening for Probe agents

       phproot                - PHP root directory
       ext                    - PHP modules directory
       ini                    - PHP ini directory       

       logdir                 - PHP probe agent logs directory

       All of the above arguments are optional for quick install.

       When PHP root directory details are not specified installer automatically discovers the php installations on the machine and installs the CA APM PHP Probe agent.
            
       ${rmso}
EOF
}


#log functions
logerror() {
  echo "ERROR: $@" >> $logfile  
}

logwarn() {
  echo "WARN: $@" >> $logfile
}

loginfo() {
  echo "INFO: $@" >> $logfile
}

readproperty() {
  #grep propertyname propertyfile
  grep "^${1}" "${2}"| cut -f 2 -d '=' | tr -d '\r' 2> /dev/null  
}

executecmd() {
  loginfo "Executing command: $@"
  "$@" >> $logfile 2>&1
  retval=$?
  loginfo "Command return value is: $retval"
  return $retval
}


#main interactive php agent installation starts here
phpagent_installation() {
 if [ "${qinstall}" -eq 0 ]; then
cat <<EOF

${bold}Configure and install CA APM PHP Probe Agent:${rmso}
EOF
  
  else
cat <<EOF

  ${bold}Installing CA APM PHP Probe Agent...${rmso}

  ${bold}Looking for PHP Installations on this machine...${rmso}
EOF
  fi  
  if [ "${qinstall}" -eq 0 ]; then
    defappname=$(readproperty $apppropertyname $agentinidir)
    agentappname=
    echo ""
    echo -n "  Enter APP name to be used by PHP agent (${bold}Press Enter${rmso} to use default value $defappname): "
    read agentappname
    if [ -z "${agentappname}" ]; then
       agentappname=$defappname       
    fi
    defipaddr=$(readproperty $ippropertyname $agentinidir)
    collipaddr=
    echo ""
    echo -n "  Enter Infrastructure Agent Host/IP address(if running on remote machine) to be used by PHP agent (${bold}Press Enter${rmso} to use default value $defipaddr): "
    read collipaddr
    if [ -z "${collipaddr}" ]; then
       collipaddr=$defipaddr       
    fi 
    defagentlogdir=$(readproperty $logpropertyname $agentinidir)
    agentlogdir=
    inputisvalid=0
    until [ "$inputisvalid" -eq 1 ]; do
      echo ""
      echo -n "  Enter PHP agent log directory(${bold}Press Enter${rmso} to use default value $defagentlogdir): "
      read agentlogdir
      if [ -z "${agentlogdir}" ]; then
        agentlogdir=$defagentlogdir
        #removing double quotes for validation of input
        agentlogdir=`sed -e 's/^"//' -e 's/"$//' <<<"$agentlogdir"`        
      fi
    
      if [ -d "${agentlogdir}" ]; then
        inputisvalid=1
      else
        logerror "  User input: $agentlogdir is not a valid directory"
        echo "${bold}  ERROR: $agentlogdir either doesn't exist or not a valid directory.Please enter valid directory${rmso}"
        continue
      fi
    done
  
    collport=
    defcollport=
    inputisvalid=0
    until [ "$inputisvalid" -eq 1 ]; do
      if [ -z "${pcollport}" ]; then
        defcollport=$(readproperty $portpropertyname $agentinidir)
      else
        defcollport=$pcollport
      fi
      collport=
      echo ""
      if [ -z "${pcollport}" ]; then
         echo -n "  Enter Infrastructure agent port(${bold}Press Enter${rmso} to use default value $defcollport): "
      else
         echo -n "  Enter Infrastructure agent port(${bold}Press Enter${rmso} to use previously entered Infrastructure agent port \"$defcollport\"): "
      fi
      read collport
      if [ -z "${collport}" ]; then
        collport=$defcollport
        #removing double quotes for validation of input
        collport=`sed -e 's/^"//' -e 's/"$//' <<<"$collport"`    
      fi
      if [ "${collport}" -gt 0 ] && [ $collport -lt 65536 ]; then
        inputisvalid=1
      else
        logerror "  User input: $collport is not a valid port"
        echo "${bold}  ERROR: $collport is not a valid port.Please enter valid port {1 to 65535}${rmso}"
        continue
      fi
    done
  fi 

  if [ "${qinstall}" -eq 1 ] ; then
     if [ -n "${phpappname}" ]; then
        agentappname=$phpappname 
     fi

     if [ -n "${probelogdir}" ]; then
        agentlogdir=$probelogdir 
     fi

     if [ -n "${phpcollip}" ]; then
        collipaddr=$phpcollip 
     fi

     if [ -n "${phpcollport}" ]; then
        collport=$phpcollport 
     fi
  fi
  getPhpInstallList
}

updateini() {
if [ -n "${agentappname}" ]; then
  executecmd sed -i -e "/^$apppropertyname=\s*/ s#=\s*.*#=\"$agentappname\"#" "$phpinidir/$agentini"
fi

if [ -n "${collipaddr}" ]; then
  executecmd sed -i -e "/^$ippropertyname=\s*/ s#=\s*.*#=\"$collipaddr\"#" "$phpinidir/$agentini"
fi

if [ -n "${agentlogdir}" ]; then
  executecmd sed -i -e "/^$logpropertyname=\s*/ s#=\s*.*#=\"$agentlogdir\"#" "$phpinidir/$agentini"
fi

if [ -n "${collport}" ]; then
  executecmd sed -i -e "/^$portpropertyname=\s*/ s#=\s*.*#=\"$collport\"#" "$phpinidir/$agentini"
fi
}


installAgent() {
installerror=
msg=
if [ -n "${phpextdir}" ] && [ -n "${phpinidir}" ] && [ -n "${phpver}" ]; then  
  phplibver=
  case "${phpver}" in
    5.3.*)
      phplibver="php53"
      ;;
    5.4.*)
      phplibver="php54"
      ;;
    5.5.*)
      phplibver="php55"
      ;;
    5.6.*)
      phplibver="php56"
      ;;
	7.0.*)
      phplibver="php70"
      ;;
	7.1.*)
      phplibver="php71"
      ;;
    *)
      installerror="Unknown PHP Version ${phpver} found during agent installation"
      logerror $installerror
      return 0;	  
      ;;
  esac	  
  
  
  cmd= 
  agentlibdir="$INSTALL_DIR/probe/lib/$phplibver/$agentlib" 
  
  if [ -e "${agentlibdir}" ];then
    if [ -e "${phpextdir}/${agentlib}" ]; then
	 msg="Over-writing php agent present at ${phpextdir} with latest version"
	 logwarn $msg	 
	fi 
    loginfo "${phpdir} -> Php agent directory =${agentlibdir}"
    executecmd cp -f "${agentlibdir}" "${phpextdir}"
        
    if [ "${retval}" -eq 0 ]; then
      if [ -e "${agentinidir}" ]; then
	     if [ -e "${phpinidir}/${agentini}" ]; then
		msg="php agent ini file ${agentini} is already present in directory ${phpinidir}. Copy skipped"
	        logwarn $msg
                retval=0
             else
                retval=executecmd cp -f "${agentinidir}" "${phpinidir}"                        
	     fi
	     
	     if [ "${retval}" -eq 0 ]; then
		updateini
	     else
             installerror="Failed to copy php agent from ${agentinidir} to ${phpinidir}"
             logerror $installerror
	     return 1    
	     fi		  
	  else
         installerror="Unable to find agent ini file in directory ${agentinidir}"
         logerror $installerror
	     return 1	 
	  fi
    else
      installerror="Failed to copy php agent from ${agentlibdir} to ${phpextdir}"
      logerror $installerror
	  return 1
    fi
  else
    installerror="Unable to find agent lib in directory ${agentlibdir}"
    logerror $installerror
	return 1
  fi    
fi
}

getPhpInstallInfo() {
  phpdir="$1"

  phpbin=
  havecfg=
  havebin=
  error= 
  if [ "${iinstall}" -eq 1 ]; then
    phpextdir=
    phpinidir=
  fi
  if [ -x "${phpdir}/php-config" ]; then
    havecfg=1
    phpbin=`${phpdir}/php-config --php-binary 2> /dev/null`    
  fi
  
  if [ -z "${phpbin}" ] || [ ! -x "${phpbin}" ]; then
      if [ -x "${phpdir}/php" ]; then
        phpbin="${phpdir}/php"
      fi
  fi
  
  loginfo "${phpdir} -> Php bin=${phpbin}"

  tmp=
  if [ -n "${phpbin}" ]; then
    havebin=1
    tmp="/tmp/caphpagent.info"
    "${phpbin}" -i > ${tmp} 2>&1    	
  fi
  
  # Get the version
  phpver=
  if [ -n "${havecfg}" ]; then    
    phpver=`${phpdir}/php-config --version 2> /dev/null`
  elif [ -n "${havebin}" ]; then
   phpver=`${phpbin} -n -d display_errors=Off -d display_startup_errors=Off -d error_reporting=0 -r 'echo phpversion();' 2> /dev/null`
  fi   
 
  if [ -z "${phpver}" ]; then
    loginfo "${phpdir} -> couldn't determine version"
    error="Could not determine the version of PHP located at ${phpdir}"
    logerror error
    return 1
  fi
  
  loginfo "${phpdir} -> Php Version=${phpver}"

  case "${phpver}" in
    5.3.*)
      ;;
    5.4.*)
      ;;
    5.5.*)
      ;;
    5.6.*)
      ;;
	7.0.*)      
      ;;
	7.1.*)      
      ;;  
    *)      
      loginfo "${phpdir} -> unsupported version '${phpver}'"
      error="Unsupported version '${phpver}' of PHP found at ${phpdir}."
      logerror error
      return 1
      ;;
  esac

  # here we get the extension and ini directories
  if [ -z "${phpextdir}" ] && [ -n "${havecfg}" ]; then
     phpextdir=`${phpdir}/php-config --extension-dir 2> /dev/null`
  fi
  	 
  if [ -n "${havebin}" ]; then
    if [ -z "${phpextdir}" ]; then
       phpextdir=`${phpbin} -r 'echo ini_get("extension_dir");'`
    fi
    if [ -z "${phpinidir}" ]; then
      phpinidir=`${phpbin} -n -d display_errors=Off -d display_startup_errors=Off -d error_reporting=0 -r 'echo PHP_CONFIG_FILE_SCAN_DIR;' 2> /dev/null` 
    fi 
  fi

  loginfo "${phpdir} -> Php ini directory=${phpinidir}" 


  if [ -z "${phpextdir}" ]; then
    error="Could not determine extension directory for the PHP installation located at ${phpdir}"
    logerror $error
    return 1
  fi

  if [ ! -d "${phpextdir}" ]; then
    error="PHP extension directory ${phpextdir}, for the PHP installation located at ${phpdir}, does not exist."
    logerror $error
    return 1
  fi

  if [ -z "${phpinidir}" ]; then
    error="Could not determine ini directory for the PHP installation located at ${phpdir}"
    logerror $error
    return 1
  fi

  if [ ! -d "${phpinidir}" ]; then
    error="PHP ini scan directory ${phpinidir}, for the PHP installation located at ${phpdir}, does not exist."
    logerror $error
    return 1
  fi
  
  loginfo "${phpdir} -> Php extension directory=${phpextdir}"

#
# Get whether or not ZTS (Zend Thread Safety) is enabled
#
  phpzts=  
  if [ -n "${havebin}" ] && [ -e "${tmp}" ]; then
    if grep 'Thread Safety' ${tmp} | grep 'enabled' > /dev/null 2>&1; then
      phpzts=Enabled
      error="PHP Zend Thread Safety (ZTS) is enabled for the PHP installation located at ${phpdir}. Please contact support@ca.com for PHP probe agent with ZTS support."
      logerror $error
      return 1
    elif grep 'Thread Safety' ${tmp} | grep 'disabled' > /dev/null 2>&1; then
      phpzts=Disabled
    fi
  fi
  
  tmpZTS=
  if [ -n "${havebin}" ] && [ -z "${phpzts}" ]; then
   tmpZTS=`${phpbin} -n -d display_errors=Off -d display_startup_errors=Off -d error_reporting=0 -r 'echo PHP_ZTS;' 2> /dev/null`
   if [ -n "${tmpZTS}" ] && [ "${tmpZTS}" -eq 1 ]; then
     phpzts=Enabled
     error="PHP Zend Thread Safety (ZTS) is enabled for the PHP installation located at ${phpdir}. Please contact support@ca.com for PHP probe agent with ZTS support."
     logerror $error
     return 1
   elif	[ -n "${tmpZTS}" ] && [ "${tmpZTS}" -eq 0 ]; then
     phpzts=Disabled
   fi	    
  fi

  if [ -z "${phpzts}" ] && [ -n "${phpextdir}" ]; then      
       case "${phpextdir}" in
         *no-zts* | *non-zts*) 
	    phpzts="Disabled"
	    ;;
         *zts*) 
	   phpzts="Enabled"
           error="PHP Zend Thread Safety (ZTS) is enabled for the PHP installation located at ${phpdir}. Please contact support@ca.com for PHP probe agent with ZTS support."
           logerror $error
           return 1
	   ;;
       esac                    
  fi
  loginfo "${phpdir} -> Php Zend Thread Safety=${phpzts}"  

  if [ -n "${tmp}" ] && [ -e "${tmp}" ]; then
    rm -f $tmp > /dev/null 2>&1
  fi
  
  if [ -z "${error}" ]; then
     if [ "${qinstall}" -eq 1 ] ; then
       agentappname=
       if [ -n "${phpappname}" ]; then
         agentappname=$phpappname 
       fi
       agentlogdir=
       if [ -n "${probelogdir}" ]; then
         agentlogdir=$probelogdir 
       fi
       collipaddr=
       if [ -n "${phpcollip}" ]; then
         collipaddr=$phpcollip 
       fi
       collport=
       if [ -n "${phpcollport}" ]; then
         collport=$phpcollport 
       fi
    fi
    installAgent
  fi
  
  return 0
}

quick_installation() {
  qinstall=1
  collport=
  agentlogdir=    
  
  
  if [ -n "${phpcollport}" ]; then 
    if [ "${phpcollport}" -gt 0 ] && [ $phpcollport -lt 65536 ]; then
      loginfo "  Quick Installation User input: $phpcollport is valid port"      
    else
      logerror "  User input: $phpcollport is not a valid port"
      echo "${bold}  ERROR: $phpcollport is not a valid port.Please enter valid port {1 to 65535}${rmso}"
      ERROR=4 
      return 1    
    fi
  fi

#  if [ -n "${phpcollport}" ] || [ -n "${phpemurl}" ]; then
#   if [ -w agentprofiledir ]; then
#     collector_installation  
#   elif [ -z "${phpcollip}" ]; then   
#      logwarn "  IA agent Profile file not found. Please manually update IA agent profile file."
#      echo "${bold}  WARN: $agentprofiledir file not found."
#   fi  
#  fi 

  if [ -n "${phprootdir}" ]; then
cat <<EOF

  ${bold}Installing CA APM PHP Probe Agent...${rmso}

EOF

     getPhpInstallInfo $phprootdir
     echo ""
     echo "${bold} Installation Overview:${rmso}"
     echo ""
     echo "${bold}1)${rmso} PHP Root : ${phpbin}"
	if [ -n "${phpver}" ]; then
	  echo "   PHP Version : ${phpver}"
	fi

	if [ -n "${phpextdir}" ]; then
	  echo "   PHP Extensions directory : ${phpextdir}"
	fi

	if [ -n "${phpzts}" ]; then
	  echo "   PHP Zend Thread Safety : ${phpzts}"
	fi

	if [ -n "${phpinidir}" ]; then
	  echo "   PHP ini directory : ${phpinidir}"
	fi

	if [ -n "${error}" ]; then
	  echo "   Installation Status : ${bold}Failed${rmso}"
	  echo "${bold}   Reason : ${error}${rmso}"
        elif [ -n "${installerror}" ]; then
          echo "   Installation Status : ${bold}Failed${rmso}"
	  echo "${bold}   Reason : ${installerror}${rmso}"
	else
	   echo "   Installation Status : ${bold}Success${rmso}"
           cat <<EOF

   CA APM PHP Probe Agent is successfully installed on your machine.

   1) To modify default CA APM PHP Probe agent settings update file ${bold}$phpinidir/$agentini${rmso}   
   2) Restart your web server or your PHP-FPM process to see performance metrics.
     
EOF
    fi
  else
    phpagent_installation
  fi
}



collector_installation() {

  if [ "${qinstall}" -eq 0 ]; then
cat <<EOF

  ${bold}Configure CA APM Infrastructure Agent:${rmso}

EOF
  
  else
cat <<EOF

  ${bold}Configuring CA APM Infrastructure Agent...${rmso}
EOF
    
  fi

  defemurl=$(readproperty $emurlpropertyname $agentprofiledir)

  if [ "${qinstall}" -eq 0 ]; then
    phpemurl=
    echo -n "  Enter Enterprise Manager Connection URL(${bold}Press Enter${rmso} to use existing value \"$defemurl\"): "
    read phpemurl
  fi

  if [ -z "${phpemurl}" ]; then
      phpemurl=$defemurl
  else
    executecmd sed -i -e "/^$emurlpropertyname=\s*/ s#=\s*.*#=$phpemurl#" "$agentprofiledir"  
  fi  

  defpcollport=$(readproperty $pcollportpropertyname $agentprofiledir) 
  
   if [ "${qinstall}" -eq 0 ]; then
     inputisvalid=0
     until [ "$inputisvalid" -eq 1 ]; do
    
      pcollport=
      echo ""
      echo -n "  Enter Port on which Infrastructure agent will accept PHP probe agent connections(${bold}Press Enter${rmso} to use existing value \"$defpcollport\"): "
      read pcollport
      if [ -z "${pcollport}" ]; then
        pcollport=$defpcollport     
      fi

      if [ "${pcollport}" -gt 0 ] && [ $pcollport -lt 65536 ]; then
        inputisvalid=1
        executecmd sed -i -e "/^$pcollportpropertyname=\s*/ s#=\s*.*#=$pcollport#" "$agentprofiledir"
      else
        logerror "User input: Infrastructure Agent Port $pcollport is not a valid port"
        echo "${bold}ERROR: $pcollport is not a valid port.Please enter valid port {1 to 65535}${rmso}"
      continue
      fi
      done
   else
     if [ -z "${phpcollport}" ]; then
        phpcollport=$defpcollport     
     fi    
     executecmd sed -i -e "/^$pcollportpropertyname=\s*/ s#=\s*.*#=$phpcollport#" "$agentprofiledir"
   fi
cat <<EOF

  ${bold}Successfully updated "$agentprofiledir" file${rmso}
EOF

}

addtopath() {   
    if [ -n "$1" ] && [ -d "$1" ]; then
        if [ -n "${PATH}" ]; then
          loginfo "$1"
          PATH="${PATH}${PATH_SEPARATOR}${1}";
        else
          PATH="$1";
        fi
    fi   
}

addDefaultPhpPaths() {
#
# Adding few known php installation paths to the PATH to search.
# There is a chance that PHP is not in PATH or PATH is not accessible
# in some user environments. 
#    
    addtopath /opt/php-5.3/bin
    addtopath /opt/php-5.4/bin
    addtopath /opt/php-5.5/bin
    addtopath /opt/php-5.6/bin
    addtopath /opt/php53_cgi/bin
    addtopath /opt/php54_cgi/bin
    addtopath /opt/php55_cgi/bin
    addtopath /opt/php56_cgi/bin
    addtopath /opt/php/bin
      
   
    addtopath /usr/local/php-5.3/bin
    addtopath /usr/local/php-5.4/bin
    addtopath /usr/local/php-5.5/bin
    addtopath /usr/local/php-5.6/bin

    addtopath /usr/local/bin
    addtopath /usr/local/php
    addtopath /usr/local/php/bin    

    addtopath /usr/php/bin
    addtopath /usr/php/5.3/bin
    addtopath /usr/php/5.4/bin
    addtopath /usr/php/5.5/bin
    addtopath /usr/php/5.6/bin	
    
    addtopath /usr/php-5.3/bin
    addtopath /usr/php-5.4/bin
    addtopath /usr/php-5.5/bin
    addtopath /usr/php-5.6/bin

    addtopath /usr/local/zend/bin
    addtopath /opt/zend/bin
    
    addtopath /app/php5.3/bin	
    addtopath /app/php5.4/bin
    addtopath /app/php5.5/bin
    addtopath /app/php5.6/bin
}

addToFinalList() {
userSel=$1
i=1

  IFS=${PATH_SEPARATOR}
  for item in $phplist; do
    if [ $i -eq $userSel ]; then
      if [ -z "${phpfinallist}" ]; then
         phpfinallist="${item}"
      else       
         phpfinallist="${phpfinallist}${PATH_SEPARATOR}${item}"
      fi
      break
    fi
    i=$((i+1))
  done
  IFS="${OIFS}"
}

getPhpInstallList() {	
        
        addDefaultPhpPaths	
	#
	# Now search for PHP installations in $PATH. We look for either php or 
	# php-config.We need this because php-config is only shipped in php-dev pkg
	#
	phplist=
	# The default value of IFS is a space, a tab, and a newline
        # Always keep the original IFS as it isn’t easy to set in the shell
	
	IFS=${PATH_SEPARATOR}       
        set -- $PATH
	while [ -n "$1" ]; do
	  phpdir=$1; shift
          
          if [ -x "${phpdir}/php" ] && [ ! -d "${phpdir}/php" ]; then
	    loginfo "PHP libraries found in ${phpdir}"
            if [ -z "${phplist}" ]; then
            phplist="${phpdir}"
            else       
	    phplist="${phplist}${PATH_SEPARATOR}${phpdir}"
            fi	    
          elif [ -x "${phpdir}/php-config" ] && [ ! -d "${phpdir}/php-config" ]; then
	    loginfo "PHP libraries found in ${dir}"
	    if [ -z "${phplist}" ]; then
            phplist="${phpdir}"
            else       
	    phplist="${phplist}${PATH_SEPARATOR}${phpdir}"
            fi
	  else
	    loginfo "PHP not found in ${phpdir}"
	  fi
	done
	IFS="${OIFS}"
        
        uentry=0
        if [ -z "${phplist}" ]; then
cat <<EOF


  Installer failed to find PHP installation on this machine
EOF
         
          inputisvalid=0
          uphpdir=          
          until [ "$inputisvalid" -eq 1 ]; do          
            echo ""
            echo -n "  Enter PHP root directory to install CA APM PHP Probe agent:"
            read uphpdir            
    
            if [ -d "${uphpdir}" ]; then
              inputisvalid=1
              uentry=1
              phpfinallist="${uphpdir}" 
            else
              logerror "  User input: PHP root dir $uphpdir is not a valid directory"
              echo "${bold}  ERROR: $uphpdir either doesn't exist or not a valid directory.Please enter valid directory${rmso}"
              continue
            fi
          done               
        fi
    
if [ "${uentry}" -eq 0 ]; then
cat <<EOF

  ${bold}Installer found following PHP installations on this machine${rmso}

EOF
        
        count=0        
	IFS=${PATH_SEPARATOR}
	for item in $phplist; do
	    count=$((count+1))
	    IFS="$OIFS"	   
	    echo "   ${count}) ${item}"
	done
	IFS="${OIFS}"

 if [ "${qinstall}" -eq 0 ]; then 
	echo ""
	echo "   0)   Exit"
	echo ""	

	 isvalid=0
	  while [ "$isvalid" = 0 ]; do
            if [ $count -gt 1 ]; then
	      echo -n "    (Select 1-${count}, or all to install, 0 to exit): "
            else
              echo -n "    (Select 1 to install, 0 to exit): "
            fi
	    read input	    
	    IFS=", "
	    if [ -n "$input" ]; then	      
	      for sel in $input; do
		  case "$sel" in		  
		  [Aa][Ll][Ll]) 
                     phpfinallist="${phplist}"
                     isvalid=1
                     ;;
		  [1-9] | [1-9][0-9])
		    if [ $sel -gt $count ]; then
		      isvalid=0
		    else
                      addToFinalList $sel		      
                      isvalid=1
		    fi
		    ;;
                  0) 
                     exit 0 
                     ;;
		  *) 
                    isvalid=0 
                    ;;
		esac
	      done
	    else
	      isvalid=0
	    fi
	    IFS="${OIFS}"
	  done
  else
     phpfinallist="${phplist}"
  fi
fi   
   
count=0
successcount=0
IFS=${PATH_SEPARATOR}
if [ "${uentry}"  -eq 1 ]; then
cat <<EOF

  ${bold}Installing CA APM PHP Probe Agent...${rmso}

EOF

elif [ "${qinstall}" -eq 0 ]; then
cat <<EOF

  ${bold}Installing CA APM PHP Probe Agent at selected PHP installation(s)...${rmso}

EOF

else
cat <<EOF

  ${bold}Installing CA APM PHP Probe Agent at all discovered PHP installation(s)...${rmso}

EOF
fi     
   
for item in $phpfinallist; do	   
      getPhpInstallInfo ${item}
          count=$((count+1)) 
          echo "" 
          if [ "${count}" -eq 1 ]; then 
cat <<EOF

  ${bold}Installation Overview:${rmso}

EOF
            
          fi     
	  echo "${bold}$count)${rmso} PHP Root : ${phpbin}"
		if [ -n "${phpver}" ]; then
		  echo "   PHP Version : ${phpver}"
		fi

		if [ -n "${phpextdir}" ]; then
		  echo "   PHP Extensions directory : ${phpextdir}"
		fi

		if [ -n "${phpzts}" ]; then
		  echo "   PHP Zend Thread Safety : ${phpzts}"
		fi

		if [ -n "${phpinidir}" ]; then
		  echo "   PHP ini directory : ${phpinidir}"
		fi

		if [ -n "${error}" ]; then
		  echo "   Installation Status : ${bold}Failed${rmso}"
		  echo "${bold}   Reason : ${error}${rmso}"
                elif [ -n "${installerror}" ]; then
                  echo "   Installation Status : ${bold}Failed${rmso}"
		  echo "${bold}   Reason : ${installerror}${rmso}"
		else
                   successcount=1
		   echo "   Installation Status : ${bold}Success${rmso}"
                   echo ""
		fi          
    done
	IFS="${OIFS}"
if [ "${successcount}" -eq 1 ]; then
 if [ "${count}" -eq 1 ]; then
cat <<EOF

   CA APM PHP Probe Agent is successfully installed on your machine.
   
   1) To modify default CA APM PHP Probe agent settings update file ${bold}${phpinidir}/${agentini}${rmso}
   2) Restart your web server or your PHP-FPM process to see performance metrics.
     
EOF
else
cat <<EOF

   CA APM PHP Probe Agent is successfully installed on your machine.   
   
   1) To modify default CA APM PHP Probe agent settings update file at PHP INI directory   
   2) Restart your web server or your PHP-FPM process to see performance metrics.
     
EOF
fi
fi
}


interactive_install() {
user_selection=
repeat=0
until [ "$user_selection" = "0" ]; do
    if [ "${repeat}" -eq 0 ]; then
      echo ""
      echo "${bold}CA APM PHP Probe Agent Installer${rmso}"     
      echo "${bold}Copyright (c) ${year} CA. All Rights Reserved.${rmso}"     
     fi
    echo ""
    echo "${bold}===================================================${rmso}"    
    echo ""
    echo "${bold}INSTALL MENU${rmso}"
    echo ""    
    echo "    1 - Configure and install ${bold}CA APM PHP Probe Agent${rmso}"
    echo ""
    echo "    0 - Exit Installer"
    echo ""
    echo -n "    Enter selection: "
    read user_selection
    repeat=$((repeat+1))
    echo ""
    case $user_selection in
        1) 
          phpagent_installation
          user_selection=0;
          ;;        
        0) 
          exit 0
          ;;
        *) 
          echo "Please enter 1  or 0"
    esac
done
}

ERROR=0
#if [ "$(id -u)" != "0" ]; then
#  echo "  ERROR: Cannot proceed with installation. This script must be run as root" 1>&2
#  ERROR=5 
#  exit $ERROR
#fi

#globals
OIFS="${IFS}"
PATH_SEPARATOR=":"
bold=`tput bold 2> /dev/null`
rmso=`tput sgr0 2> /dev/null`

THIS_OS=`uname -a | cut -d ' ' -f 1`
SCRIPTNAME="${BASH_SOURCE[0]}"
INSTALL_DIR=
if [ "${OSTYPE}" = "linux-gnu" ]; then
	SCRIPTNAME=`readlink -f "${BASH_SOURCE[0]}"`;
	INSTALLENABLED=true
fi

if [ -z "${INSTALL_DIR}" ]; then
        INSTALL_DIR="$( cd "$( dirname "$SCRIPTNAME" )" && pwd )";       
        export INSTALL_DIR
fi


#php agent install logger
year=`date +%Y 2> /dev/null`
logtime=`date +%Y%m%d_%H%M%S 2> /dev/null`
logfile=${INSTALL_DIR}/caphpagent_install_${logtime}.log

#php agent globals
agentlib="wily_php_agent.so"
agentini="wily_php_agent.ini"
agentinidir="$INSTALL_DIR/probe/$agentini"

logpropertyname="wily_php_agent.logdir"
portpropertyname="wily_php_agent.collectorPort"
ippropertyname="wily_php_agent.collectorHost"
apppropertyname="wily_php_agent.application.name"

#IA agent globals
infraagentprofile="IntroscopeAgent.profile"
infraagentprofiledir="$INSTALL_DIR/apmia/core/config/$infraagentprofile"
saasinfraagentprofiledir="$INSTALL_DIR/core/config/$infraagentprofile"
emurlpropertyname="agentManager.url.1"
pcollportpropertyname="introscope.remoteagent.collector.tcp.port"

agentprofiledir= 
if [ -e "${saasinfraagentprofiledir}" ]; then
  agentprofiledir=$saasinfraagentprofiledir
else
  agentprofiledir=$infraagentprofiledir
fi 

phpappname=
phprootdir=
phpinidir=
phpextdir=
phpcollip=
phpcollport=
phpemurl=
probelogdir=
iinstall=0
qinstall=0
while [ "$1" != "" ]; do
    case $1 in
        -i | -install )
            iinstall=1
            interactive_install	    
            ;;
        -appname)
            shift		
            phpappname=$1
            ;;
        -phproot)
            shift		
            phprootdir=$1
            ;;
	    -ini)
            shift		
            phpinidir=$1
            ;;
        -ext)
            shift		
	        phpextdir=$1
            ;;
        -iahost)
            shift		
	        phpcollip=$1
            ;;
         -iaport)
            shift		
	        phpcollport=$1
            ;;       
        -logdir)
            shift		
	        probelogdir=$1
            ;;         
        -h | --help | *)
            usage
            exit 1		
    esac
    shift
done

if [ "${iinstall}" -eq 0 ]; then 
  quick_installation
fi

exit $ERROR