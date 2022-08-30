#!/usr/bin/fish
# parametros REPO MODULE

set REPO $argv[1]
set MODULE $argv[2]
set USER_ORG tecnativa
git clone https://github.com/OCA/$REPO -b 15.0
cd $REPO
git checkout -b 15.0-mig-$MODULE origin/15.0
git format-patch --keep-subject --stdout origin/15.0..origin/14.0 -- $MODULE | git am -3 --keep
cd $MODULE
pre-commit run -a  # to run black and isort (ignore pylint errors at this stage)
git add -u
git commit -m "[IMP] $MODULE: black, isort"  --no-verify  # it is important to do all Black formatting in one commit the first time
find . -type f -name '__manifest__.py' | xargs sed -i 's/14.[0-9].[0-9].[0-9].[0-9]/15.0.1.0.0/g'
oca-gen-addon-readme  --repo-name (basename (dirname (pwd))) --branch 15.0 --addon-dir . --no-commit
cd ..
git add --all
git commit -m "[MIG] $MODULE: Migration to v15.0"
pre-commit run -a  # to run black and isort (ignore pylint errors at this stage)
git remote add $USER_ORG git@github.com:$USER_ORG/$REPO.git
git push $USER_ORG 15.0-mig-$MODULE --set-upstream
