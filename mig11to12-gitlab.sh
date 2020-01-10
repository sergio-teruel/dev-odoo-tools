#!/usr/bin/fish
# parametros REPO MODULE

set REPO $argv[1]
set MODULE $argv[2]
rm $REPO -rf
git clone git@gitlab.tecnativa.com:Tecnativa/$REPO.git -b 12.0
cd $REPO
git checkout -b 12.0-mig-$MODULE origin/12.0
git format-patch --keep-subject --stdout origin/12.0..origin/11.0 -- odoo/custom/src/private/$MODULE | git am -3 --keep
git add --all
git push origin 12.0-mig-$MODULE --set-upstream
