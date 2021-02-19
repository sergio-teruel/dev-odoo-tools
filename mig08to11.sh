#!/usr/bin/fish
# parametros REPO MODULE

set REPO $argv[1]
set MODULE $argv[2]
set USER_ORG tecnativa
git clone https://github.com/OCA/$REPO -b 11.0
cd $REPO
git checkout -b 11.0-mig-$MODULE origin/11.0
git format-patch --keep-subject --stdout origin/11.0..origin/8.0 -- $MODULE | git am -3 --keep
git add --all
git remote add $USER_ORG git@github.com:$USER_ORG/$REPO.git
git push $USER_ORG 11.0-mig-$MODULE --set-upstream
