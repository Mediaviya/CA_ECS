<?php
/*
* Copyright (c) 2014 CA. All rights reserved.
*
* This software and all information contained therein is confidential and proprietary and
* shall not be duplicated, used, disclosed or disseminated in any way except as authorized
* by the applicable license agreement, without the express written permission of CA. All
* authorized reproductions must be marked with this language.
*
* EXCEPT AS SET FORTH IN THE APPLICABLE LICENSE AGREEMENT, TO THE EXTENT
* PERMITTED BY APPLICABLE LAW, CA PROVIDES THIS SOFTWARE WITHOUT WARRANTY
* OF ANY KIND, INCLUDING WITHOUT LIMITATION, ANY IMPLIED WARRANTIES OF
* MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT WILL CA BE
* LIABLE TO THE END USER OR ANY THIRD PARTY FOR ANY LOSS OR DAMAGE, DIRECT OR
* INDIRECT, FROM THE USE OF THIS SOFTWARE, INCLUDING WITHOUT LIMITATION, LOST
* PROFITS, BUSINESS INTERRUPTION, GOODWILL, OR LOST DATA, EVEN IF CA IS
* EXPRESSLY ADVISED OF SUCH LOSS OR DAMAGE.
*/

  /*
   * Note:  since apache processes are forked into a sleep state, a given
   * process may report a 0 size blacklist on first request after it wakes up.
   * That process will synchronize itself, but there may be a period where 
   * the entire blacklist count is not reported.
   *  
   *  Also, calling this function may cause the function to be put on the blacklist itself, depending
   *  on trace settings.  A first call would return 0 size, then subsequent calls return 1.
   */
  header('Content-type: text/plain');
  $blsize = wily_php_agent_blacklist_size();
  echo "$blsize";
  unset($blsize);
?>