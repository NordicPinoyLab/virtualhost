#!/bin/bash

### You may edit the following parameters:
action=$1
domain=$2
rootDir=$3
owner=$(who am i | awk '{print $1}')
email='sysadmin@example.com'
userDir='/var/www/webapps/'
publicDir='web'
sitesAvailable='/etc/apache2/sites-available/'
sitesAvailabledomain=$sitesAvailable$domain.conf

### Do not modify below unless you know what you are doing ####

if [ "$(whoami)" != 'root' ]; then
	echo $"You have no permission to run $0 as non-root user. Use sudo"
		exit 1;
fi

if [ "$action" != 'create' ] && [ "$action" != 'delete' ]
	then
		echo $"You need to prompt for action (create or delete)"
		exit 1;
fi

while [ "$domain" == "" ]
do
	echo -e $"Please provide the domain. e.g. example.com"
	read -r domain
done

if [ "$rootDir" == "" ]; then
	rootDir=${domain}
fi

### If rootDir starts with '/', then don't use /var/www/webapps as parent directories.
if [[ "$rootDir" =~ ^/ ]]; then
	userDir=''
fi

rootDir=$userDir$rootDir

if [ "$action" == 'create' ]
	then
		### Check if domain already exists
		if [ -e "$sitesAvailabledomain" ]; then
			echo -e $"The domain you specified already exists.\nPlease use another one."
			exit;
		fi

		### Check if directory exists or not
		if ! [ -d "$rootDir" ]; then
			### Create the directories
			mkdir -p "$rootDir/$publicDir"
			### Set permissions to rootDir and publicDir
			chmod 755 "$rootDir" "$rootDir/$publicDir"
			### write test file in the new domain public directory
			if ! echo "<?php echo phpinfo(); ?>" > "$rootDir/$publicDir/info.php"
			then
				echo $"Error: Not able to write in file $rootDir/$publicDir/info.php. Please check permissions"
				exit;
			else
				echo $"Added content to $rootDir/$publicDir/info.php"
			fi
		fi

		### Create virtualhost file
		if ! echo "
    <VirtualHost *:80>
        ServerName $domain
        ServerAlias www.$domain
        ServerAdmin $email
    
        DocumentRoot $rootDir/$publicDir
    
        <Directory />
            AllowOverride All
        </Directory>
        <Directory $rootDir/$publicDir>
            Options FollowSymLinks
            AllowOverride All
        </Directory>
    
        ErrorLog $rootDir/logs/error.log
        CustomLog $rootDir/logs/access.log combined
    </VirtualHost>" > "$sitesAvailabledomain"
		then
			echo -e $"There is an error creating the VirtualHost file for $domain"
			exit;
		else
			echo -e $"\nNew VirtualHost for $domain has been created.\n"
		fi

    # Create the logs directory
    mkdir "$rootDir/logs"

    # Set directory and file permissions
		chown -R  "$owner":www-data "$rootDir"; chmod -R g+rw "$rootDir"; find "$rootDir" -type d -print0 | xargs -0 chmod g+s

		### Enable the website
		a2ensite "$domain"

		### Restart Apache
		/etc/init.d/apache2 reload

		### show the finished message
		echo -e $"Done! \n The new VirtualHost has been created. \nThe website is at: http://$domain \nThe project directory is located at \"$rootDir\" \nThe public serving files are at \"$rootDir\"/$publicDir"
		exit;
	else
		### check whether domain already exists
		if ! [ -e "$sitesAvailabledomain" ]; then
			echo -e $"This domain does not exist.\nPlease try another one."
			exit;
		else
			### disable website
			a2dissite "$domain"

			### restart Apache
			/etc/init.d/apache2 reload

			### Delete virtual host rules files
			rm "$sitesAvailabledomain"
		fi

		### check if directory exists or not
		if [ -d "$rootDir" ]; then
			echo -e $"Delete directory for $domain? (y/n)"
			read -r deldir

			if [ "$deldir" == 'y' ] || [ "$deldir" == 'Y' ]; then
				### Delete the directory
				rm -rf "$rootDir"
				echo -e $"Directory for $domain deleted."
			else
				echo -e $"Directory for $domain kept."
			fi
		else
			echo -e $"Directory for $domain not found. Ignoring."
		fi

		### show the finished message
		echo -e $"Done!\nYou just deleted the  VirtualHost $domain."
		exit 0;
fi
