#!/usr/bin/fish
# parametros REPO MODULE BRANCH

set REPO $argv[1]
set MODULE $argv[2]
set BRANCH $argv[3]
set USER_ORG tecnativa
git clone https://github.com/OCA/$REPO -b 13.0
cd $REPO
git remote add Tecnativa https://github.com/Tecnativa/$REPO.git
git fetch Tecnativa $BRANCH
git checkout -b 13.0-mig-$MODULE origin/13.0
git format-patch --keep-subject --stdout origin/13.0..Tecnativa/$BRANCH -- $MODULE | git am -3 --keep
cd $MODULE
pre-commit run -a  # to run black and isort (ignore pylint errors at this stage)
git add -u
git commit -m "[IMP] $MODULE: black, isort"  --no-verify  # it is important to do all Black formatting in one commit the first time
# Remove all multi decorators
find . -type f -name '*.py' | xargs sed -i '/@api.multi/d'
find . -type f -name '__manifest__.py' | xargs sed -i 's/12.[0-9].[0-9].[0-9].[0-9]/13.0.1.0.0/g'
# Remove all view_type definitions from xml views
find . -type f -name '*.xml' | xargs sed -i '/field name="view_type"/d'
oca-gen-addon-readme  --repo-name (basename (dirname (pwd))) --branch 13.0 --addon-dir . --no-commit
cd ..
git add --all
git commit -m "[MIG] $MODULE: Migration to v13.0"
pre-commit run -a  # to run black and isort (ignore pylint errors at this stage)
git remote add $USER_ORG git@github.com:$USER_ORG/$REPO.git
git push $USER_ORG 13.0-mig-$MODULE --set-upstream
