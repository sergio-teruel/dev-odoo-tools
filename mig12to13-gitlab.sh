#!/usr/bin/fish
# parametros REPO MODULE

set REPO $argv[1]
set MODULE $argv[2]
rm $REPO -rf
git clone git@gitlab.tecnativa.com:Tecnativa/$REPO.git -b 13.0
cd $REPO
git checkout -b 13.0-mig-$MODULE origin/13.0
git format-patch --keep-subject --stdout origin/13.0..origin/12.0 -- odoo/custom/src/private/$MODULE | git am -3 --keep
cd odoo/custom/src/private/$MODULE
# Remove all multi decorators
find . -type f -name '*.py' | xargs sed -i '/@api.multi/d'
find . -type f -name '__manifest__.py' | xargs sed -i 's/12.[0-9].[0-9].[0-9].[0-9]/13.0.1.0.0/g'
# Remove all view_type definitions from xml views
find . -type f -name '*.xml' | xargs sed -i '/field name="view_type"/d'
oca-gen-addon-readme  --repo-name (basename (dirname (pwd))) --branch 13.0 --addon-dir . --no-commit
cd ..
git add --all
git commit -m "[MIG] $MODULE: Migration to v13.0"
git push origin 13.0-mig-$MODULE --set-upstream
