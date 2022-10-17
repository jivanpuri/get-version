# Get-Version
Provides automated versioning of your commits using git tags each time your CI/CD workflow runs.
## Features
* Generate a new version based on the last tag present & currently checked out branch.
* Commit message decides which version to bump.
## Version Format
\<major\>.\<minor\>.\<patch\>\[-\<branch-name\>\]
### Examples
## Pushing new build
Get-Version will always use the latest tag that was pushed to determine next version. A standard commit message will drive the increment in major or minor version number.
### Commit
```
git commit -m "Adding a new file"
```
### Example
1.0.7 -> 1.0.8
## Pushing new minor revision
A commit message with the substring '#minor' will increment your version's minor revision. 
### Commit
```
git commit -m "Updating dependencies #minor"
```
### Example
1.0.7 -> 1.1.7
## Pushing new major revision
A commit message with the substring '#major' will increment your version's major revision. 
### Commit
```
git commit -m "Adding breaking changes #major"
```
### Example
1.0.7 -> 2.0.7
### !Note!
If no tags are found then initial version is set to 1.0.0
## Inputs
* **production-branch**: The branch to use for stable releases in production. Default is master
## Outputs
* **version**: The new version that was created and tagged in the format of \<major\>.\<minor\>.\<build\>\[-\<dev\>\]
## Setup
```yml
- name: Checkout  
  uses: actions/checkout@v2  
  with:  
      fetch-depth: 0  
      
- name: Version  
  id: version  
  uses: jivanpuri/get-version@v1  
  with:  
      production-branch: master    
```
