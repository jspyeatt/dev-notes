
# Git Developer Notes
My notes on how to use git. Most of this has to do with file management for a local repository
but there should be a fair amount of stuff having to do with remote ones as well.

## Glossary

* fetch
* rebase
* repository



## File States
1. Untracked - git doesn't know about the file yet. This would happen if you've created a file but
   haven't done a `git add` or subsequent `git commit` on it yet.
1. Modified - git is familiar with the file meaning at some point in its past it was `git add`ed
   or `git commit`ed. Since that time the file has now been modified.
1. Staged - The file has been created or modified and a `git add` has been performed. So the file
   has been staged for committing. But could still be reset to the previous version if desired.
1. Unmodified - git knows about the file, but it hasn't changed since it was last committed.
1. Stashed - files that have been **modified** but have been put in a dirty working directory
             so you can revert to a clean directory.

## Common Activities

### Very Simplest Activity
```
git init .             # Creates a local git repository
```
Now, using an editor create a file you want to save. Ex. Fred.txt.
Check the status of the repository and note that Fred.txt is listed as Untracked.
```
git status            # displays the current status of your local repository
Untracked files:
  (use "git add <file>..." to include in what will be committed)
     Fred.txt
```
Now add Fred.txt to the repository and check the status again
```
git add Fred.txt      # This adds the file to the repo so it is now tracked and staged, ready for commit.
git status            # displays the current status of your local repository
Changes to be committed:
  (use "git rm --cached <file>.." to unstage)
  
     new file:   Fred.txt
```
Now that the file is staged for the commit you can commit the change and verify it in the log.
```
git commit -m "added the file Fred.txt"            # permanently adds all staged files to repo.

1 file changed, 3221 insertions(+)
create mode 100644 Fred.txt

git log                                            # list the commit log for the repo
commit 054b236b5607a0ff7e568c6435e552a53272ab7d
Author: John Pyeatt <john.pyeatt@singlewire.com>
Date:   Wed Aug 23 14:16:43 2017 -0500

    added the file Fred.txt
    
git status                                         # status should no longer list Fred.txt as a file that needs action taken.
```

### Create a New Branch
Good explanation of [branching](http://www.gitguys.com/topics/creating-and-playing-with-branches/).
```
git checkout master               # checkout the branch you want to branch from
git pull origin master            # make certain that branch is up to date with remote
git checkout -b new_branch_name   # create the new branch
git push origin new_branch_name   # push new branch to remote
```

### Find Parent Branch
```bash
git show-branch -a | grep '\*' | grep -v `git rev-parse --abbrev-ref HEAD` | head -n1 | sed 's/.*\[\(.*\)\].*/\1/' | sed 's/[\^~].*//'
```
### Delete a Local Branch
```
git branch -d <local-branch-name>
```
### Revert Changes
Reverting changes is done via either one of two mechanisms depending on the state of the file.

If the file is modified. Will change to previous unmodified version.
```
git checkout <filename>
```

If the file is staged (added, but not yet committed). Will move it back to working directory.
```
git reset HEAD <filename>
```
### Checking out a Specific Commit from a Branch then Setting it back
You can checkout files from a specfic commit SHA and then when you are done reset to most recent.

#### Checkout Specific Commit
```
git log
commit a1d961df42457c993e79a36c89478d249721ebfb
Author: John Pyeatt <john.pyeatt@singlewire.com>
Date:   Tue Jul 16 17:42:25 2019 -0500

    Back to no plugins configuration. Also changed Jenkinsfile to see if GIT_COMMIT is there.

commit 2e48447289801c2b1fd383584059f3276c1fa571
Author: John Pyeatt <john.pyeatt@singlewire.com>
Date:   Tue Jul 16 10:52:46 2019 -0500

    Changed an error message to a warning in icap service.

commit 7e59b96b8484bca7004f99f76dc301a7e2e2f79a
Merge: b10e858 ae20bd7
Author: Charlie Ciccia <charlie.ciccia@singlewire.com>
Date:   Tue Jul 16 15:19:58 2019 -0500

    Merge branch 'feature/SW-8089' into 'release/2019-foxtrot'
    
    First crack at adding syncId properties to Messages, Bells, Ring Lists,...
    
    See merge request fusion/InformaCast!123

```
```
git checkout 7e59b96b8484b
```
Now you should be on at the point where the First Crack commit was performed.
#### Reset to most recent
After you've checked out the specific commit you can bring everything back to most current commits by entering.
```
git pull --rebase origin BRANCH_NAME # where BRANCH_NAME is your current branch.
```
### Merge Branches
```
git checkout branchB     # branchB has changes you want to pull into branchA
git pull branchB         # make certain your local branchB is up to date with remote
git checkout branchA     # switch to branchA
git pull branchA         # make certain your local branchA is up to date with remote
git merge branchB        # merge branchB into branchA
```

### Perform Merge Request from GitLab
Merging inbound-cap-matts back into inbound-cap.
```
git fetch origin
git checkout -b feature/inbound-cap-matts origin/feature/inbound-cap-matts
# Review the changes locally
git checkout feature/inbound-cap
git merge --no-ff feature/inbound-cap-matts
git push origin feature/inbound-cap
```
### Undo a Merge that hasn't been Committed
```
git log        # get the commit_sha number you want to go back to.
git reset --hard commit_sha
```
### Undo a Merge that was committed to remote repo.
Occasionally you really screw something up and merge a dev branch into your master on the remote server
when you didn't mean to. So to undo this, you need to find the last good commit in master, hard reset it,
and push the change. This will wipe out all subsequent changes in your master.

```bash
git checkout master
git log             # find the SHA of the last good commit to master.
git reset --hard SHA_OF_LAST_GOOD_MASTER_COMMIT   # reset the master branch to the last good commit.
git push -f origin master  # push your master change back to the remote repo.
```

### Test for Merge Conflicts without Committing in the First Place
Checking for conflicts when merging from devBranch into rootBranch.
```
git checkout rootBranch
git merge devBranch --no-ff --no-commit
```
Then when you've reviewed the conflicts to get back to your original state
```
git merge --abort
```

`-no-ff` Generate a merge commit even if the merge resolved as a fast-forward.

`–no-commi`t With –no-commit perform the merge but pretend the merge failed and do not autocommit, to give the user a chance to inspect and further tweak the merge result before committing.

### Resolving Merge Conflicts of Binary Files
Sometimes when you do a merge you will see the following:
```
warning: Cannot merge binary files: /src/foo.bin (HEAD vs. release/2019-foxtrot)
warning: Cannot merge binary files: /src/bar.bin (HEAD vs. release/2019-foxtrot)
```
So how you resolve this is as follows:
#### Keep the version in your current branch
```
git checkout --ours -- src/foo.bin
git add src/foo.bin
```
#### Keep the version in the branch you are trying to merge in
```
git checkout --theirs -- src/bar.bin
git add src/bar.bin
```
Then commit the merge as normal.

### Rebasing a branch
Rebasing is similar to merging in the sense the end result of the process has hopefully
pulled in all of the changes from the two branches. But they do this in different ways.

When a rebase encounters conflicts when trying to bring a particular commit into your branch
it will stop. Unlike merge which will try to keep going. When you resolve the conflicts with
individual files you need to do a `git add` then a `git rebase --continue` and rebase will
move on to more files that have issues. Rinse and repeat.

```
git checkout master
git pull origin master
git checkout feature
git merge master
```
![](https://wac-cdn-a.atlassian.com/dam/jcr:e229fef6-2c2f-4a4f-b270-e1e1baa94055/02.svg?cdnVersion=ey)

```
git checkout master
git pull origin master
git checkout feature
git rebase master
```
![](https://wac-cdn-a.atlassian.com/dam/jcr:5b153a22-38be-40d0-aec8-5f2fffc771e5/03.svg?cdnVersion=ey)

### Stashing Files
Stashing is the process of moving files that have been modified to a storage directory and
bringing the actual working directory to a clean state. This is usually done when you have modified
some files but want to pull in remote branch changes. git won't let you do that when you have files
in a modified state. So you `stash` them to the storage directory, then do the `pull`. Then
you can bring your stashed files back into your working directory.

Assume files a.txt and b.txt have been modified in your current working directory.
```
git stash list                 # list any current stashes you have.
git stash                      # moves files to storage directory
git stash save "My comment"    # add a custom comment to your stash
git stash show                 # shows the list of files in the most recent stash
git stash list                 # should now see your stashed manifest. {0} == most recent stash
git stash show stash@\{1\} -p  # shows all of the file changes in the stash

# now you can do your pulls, merges or checkouts
# after you are done you can bring your stashed files back into your working directory

git stash pop
```
### Create new Local Repository
```
git init .     # run from the base directory of the project.
```
If you do a `git init .` then want to create a remote repo on github.com and push the local repo
you already created you need to follow these steps.

1. If you don't have an ssh keypair generated on your local machine which is also available on
github follow the steps described [here](https://help.github.com/articles/connecting-to-github-with-ssh/)
1. Then perform a `git remote add origin git@github.com:jspyeatt/cpplinkedlist.git`
1. `git push origin master`

### Move a Tracked File to Another Location
```
git mv <old-file-path> <new-file-path>
```
### Remove a Tracked File
```
git rm <file-to-remove>
```
### List Files Changed as Part of a Paricular Commit
```
git diff-tree --no-commit-id --name-only -r <commit_id>
```

### Merge Files from a Particular Commit into a Different Branch
If you have two branches `branchA` and `branchB` and branchB has commit adfb298732 with changes you want to pull
into branchA.
```
git checkout branchA
git cherry-pick adfb298732
```
### Tagging a Commit
Find the commit_id you want to tag (ex. de982a).
```
git tag release-1234 de982a      # tag the commitid with the name release-1234
git push origin release-1234     # push the tag to the remote repository
```

Then if you want to checkout a particular tag
```
git tag -l      # list all tags
git checkout <tag-name>
```

## git commands
```
git help --a    # list all subcommands
```

### git config - Tell or Show git About You or Your Repository

The result of all of this writes to your `~/.gitconfig` file.
```
git config --list           # list all configuration settings
git config --list --global  # list your user settings regardless of repository
git config --list --local   # list settings for your current repository
```
#### git config examples
* git config --global user.name="Fred Derf"
* git config --global user.email="fred.derf@example.com"
* git config --global color.diff auto
* git config --global color.status auto
* git config --global color.branch auto
* git config --global core.excludesfile ~/.gitignore

### git add

### git branch

```
git branch           # lists the local branches (current branch highlighted)
git branch --all     # lists all branches including remotes
```

### git checkout

### git cherry-pick

### git clone

### git commit

#### changing a commit message.
If you want to change the commit message of the last commit of your local repo you can do a 
```
git commit --amend
```
That's the easy one.

If you need to change a commit message on a commit other than HEAD you need to do an interact rebase. [https://linuxize.com/post/change-git-commit-message/](Here it is explained). 

### git diff

#### git diff - give summary
```
git diff --name-only
```

#### git diff  - between commits
Note, this will show all differences between commits even if there are intermediate commits between
old-commit and new-commit.
```
git diff <old-commit-id> <new-commit-id>
git diff <old-commit-id> <new-commit-id> fileName

```

### git difftool

### git fetch - download objects from another repository, usually remote.

```
git fetch --all    # fetches all remote branches.
```

### git init - Create a Repository in your Current Directory

### git log and git show

#### List files changed for a particular commit

```
git show --name-only SHA
```

#### Find Which commits modified a file

```
git log --follow <filename>
```
#### Show line changes in each commit
```
git log -p <filename>
```
#### Show graphical representation of git log.
```
git log --all --decorate --oneline --graph
```
### git merge

To merge changes from branchB into branchA. It is very important to pull in the latest,
remote changes from the branchB before merging it into branchA.

```
git checkout branchB      # switch to master branch.
git pull origin branchB   # pull in all master branch changes from remote. VERY IMPORTANT!!
git checkout branchA      # make branchA your current branch
git merge branchB         # perform the merge
```

Hopefully everything will merge without conflict. But that doesn't always happen. If there is a conflict the merge
command will tell you. When there is a conflict the file will the conflict will be decorated to indicate where the
conflicts are. Here's an example. The word `HEAD` refers to the current (branchA) branch.

```
This is a line in the file with no conflict.
<<<<<<<< HEAD
This is a conflicted section as it exists in branchA
========
This is a conflicted section as it exists in master
>>>>>>>> master
```

### git mv

### git pull
`git pull` is like `git fetch` plus `git merge`.

### git push

### git rebase

### git remote
This command describes/sets the relationship between your local repository and
a remote one. The remote one is used when you push/pull/fetch from/to the remote
location.
#### git remote -v 
Lists your fetch and push remote urls. It will list two columns the first is the
remote server (usually `origin`) the second is the full url of the project.

#### git remote add origin &lt;full git url&gt;

```
git remote add origin git@gitlab.blah.com:icmobile/cap-feed-generator.git
```

#### git remote set-url 
Changes the remote url queried by your git client when looking for updates.
```
git remote set-url origin git@gitlab.blah.com:icmobile/dev-environment.git 
```

### git reset

### git revert

### git rm

### git show

### git stash

### git status

### git tag
Allows you to make specific commits as being important.
```
git tag              # lists all tags
git tag -l "v1.8*"   # lists all tags with a certain pattern
```
Create an annotated tag (-a) for a specific commit
```
git tag -a v1.4 -m "This is the 1.4 release"
```
If you then run `git show v1.4` it will display tag details.

To tag a commit that is older than your most recent commit.
```
git log --pretty=oneline
15027957951b64cf874c3557a0f3547bd83b3ff6 Merge branch 'experiment'
a6b4c97498bd301d84096da251c98a07c7723e65 beginning write support
0d52aaab4479697da7686c15f77a3d64d9165190 one more thing
6d52a271eda8725415634dd79daabbc4d9b6008e Merge branch 'experiment'

git tag -a v1.5 0d52aaab44
```
The above tags are also only applied to your local repository. If you
want them to be available remotely you need to push them.
```
git push origin v1.5
```
Finally, if you want to checkout a specific tagged version.
```
git checkout -b myversion1.5 v1.5    # creates branch myversion1.5 and extract at commit v1.5
```
## Sample Scenarios

### Merging


## Undoing Something You Didn't Mean to do

### Undo a recent git commit
Let's say you just committed a change to your local repo and you want to undo it.

```
git log          # make note of most recent commit hash
git revert <hash found in git log>
```
This will prompt you like any other commit. It's done like this so you don't lose history.

## Useful Links


## Git Notes from Udemy Training
```bash
git config --global user.name "John Pyeatt"
git config --global user.email "jspyeatt@gmail.com"
git config --global --list
```

```bash
git init fresh-project   # creates a folder called fresh-project and sets up git.
git init .   # initializes the current folder to be managed by git
rm -rf .git  # removes the actual local repo from the directory. Your actual project files should still there.
```

A git fork is creating a copy of somebody elses repo into your own account.

global git config file in $HOME/.gitconfig
```bash
git ls-files  # lists all the files git is tracking.
```

```bash
git reset HEAD <filename>  # moves the file out of staging and back into the working directory.
```
```bash
git log --oneline --graph --decorate

git log --all --graph --decorage --oneline

git log 347abc..5439bcd

git log --since="3 days ago"

git log -- <filename>   # commits that include the specific file.

git log --follow -- <filename>   # follows renames of file.
```
```bash
git show SHA_VALUE   # shows the commit id, along with the diff of what changed in that commit.

git commit --amend   # allows you to amend the comment in your last commit.
```
### creating alias
```bash
git config --global alias hist "log --all --graph --decorate --oneline"
git hist
```
```bash
git diff README.md  # compares working directory with staging area
git diff HEAD README.md  # compares working directory with local repo
git diff --staged HEAD README.md  # compares staged area with local repo
git diff HEAD HEAD^   # compares last commit with second last commit
git diff master origin/master # compare local repo versus remote for master branch.
```
```bash
git branch -a   # lists local and remote branches
```
```bash
git pull --rebase origin master  # merges in changes from origin/master as a rebase instead of merge.
```
```bash
git stash save
git stash apply   # brings back the stashed files, but leaves them in the stash state as well.
git stash drop    # removes the stashed fiels from the stash state.

git stash -u  # just like git stash save except it will also stash untracked files.
git stash save "my custom stash message"
git stash show stash@{1} # shows the details of the second stash.
git stash apply stash@{1}  # applies the second stash back to your working directory.
git stash drop stash@{1}  # drop second stash
git stash clear  # drops all stashes.
git stash branch feature/newbranch  # creates a new branch, changes to that branch and pops your stashes into the new branch.
```
```bash
git tag myTag   # creates a lightweight tag on a current commit.
git tag --list  # lists the tags
git show myTag # shows commit details at that tag
git tag --delete myTag  # deletes the tag

# annotated tag is a lightweight tag with some added info
git tag -a v-1.0   # creates an annotated tag. It will prompt you for a message to associate to the tag.
git show v-1.0  # lists the annotation.
git tag -a v0.9 86954bdf3    # annotation tag a specific commit
git push origin v0.9  # pushes a tag to the remote repo
git push origin master --tags  # does a regular push and makes certain all tags are pushed as well.
```


### resetting
```bash
git reset HEAD^2  # backup 2 commits
git reset HEAD^^  # backup 2 commits
git reflog    # lists what you've done on reset. good way to see all your commits you've backed off from.
```

### cherry pick
```bash
git checkout feature/mybranch
git cherry-pick 493fde    # will pull in a specific commit (493fde) from another branch into feature/mybranch
```

## Trick commands

### List the files committed most often

You could also throw a --since="2021-08-21" to see only commits since Aug 21.

```
git log --pretty=format: --name-only | sort | uniq -c | sort -rg | head -10
```
