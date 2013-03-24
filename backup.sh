To use this script:
  - Optionally, create a new user (I have a netbackup user that does all my backups)
  - Install this script somewhere (I use ~netbackup/bin)
  - Edit the script to suit your needs (you'll need to change $user and $projects)
  - Put this cript in your crontab to run once per day


#!/bin/sh

user=
projects="project1 project2"
host=rubyforge.org
cvsdir=/var/cvs

backup_project()
{
project=$1

mkdir -p ~/${project}
cd ~/${project}

date=`date +%Y%m%d`
last_backup_tarball=`ls -1 *.tar.gz 2>/dev/null | sort | tail -1`

rm -rf ${project}
scp -r ${user}@${host}:${cvsdir}/${project} .
tar cvfz ${project}-${date}.tar.gz ${project}

if [ ${last_backup_tarball} != "" ]; then
  rm -rf difftmp
  mkdir difftmp
  cd difftmp
  tar xvfz ../${last_backup_tarball}
  cd ..
  echo "Comparing backups..."
  diff -r difftmp/${project} ${project}
  if (( ! $? )); then
    echo "No difference since last backup; removing"
    rm -f ${project}-${date}.tar.gz
  fi
fi

cd -
}

for p in $projects; do
  backup_project ${p}
done