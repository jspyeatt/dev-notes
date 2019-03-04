# Bash shell tricks

## Looping Through Command Line Args
```bash
while [[ $# > 0 ]]
do
   arg=$1

   case "$arg" in
      --puppetmaster)
         shift
         masterDns=$1
         ;;
      --environment)
         shift
         environment=$1
         ;;
   esac
   shift
done

```
## Setting Default Variable Values
```bash
# if the variable 'inp' has a value, use it. Otherwise set to the string localhost
host=${inp:-localhost}
```
