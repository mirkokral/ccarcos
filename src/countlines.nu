#/usr/bin/nu
mut lines = []; 
for x in (ls **/*.lua | get name) {
  $lines = ($lines | append (cat $x | wc -l | into int));
}; 
print ($lines | math sum)
