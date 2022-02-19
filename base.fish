set -U fish_greeting

abbr z sudo zypper
abbr cff vim ~/.config/fish/config.fish
abbr cfv vim ~/.config/nvim/init.vim
abbr cfb vim ~/.bashrc

# git
abbr gs git status
abbr ga git add .
abbr gas "git add . ; git status"
abbr gc git commit -m
abbr gp git push
abbr gu git pull
abbr gb git branch
abbr gm git merge
abbr gk git checkout
abbr gl git log
abbr gcn git config --local user.name
abbr gce git config --local user.email
abbr gcg git config --global --edit
abbr gdh git diff HEAD

# utils
abbr fff find / -xdev -type f -name
abbr ffd find / -xdev -type d -name
abbr ff find . -xdev -type f -name
abbr fd find . -xdev -type d -name
