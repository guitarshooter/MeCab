#!/bin/sh

for file in $*
do
  grep -E "できるので|できるとともに、|でき、また|できて、|可能になり、|可能と|できるようになる。|出来る|出来、|でき、かつ|できると共に、|できるとともに|出来るので、|できるようになり、|出来る。|できると共に| できるから、|でき|できる、|可能であり、|できた。|可能で、|できるし、|できる。|でき、より|でき、かつ、|できる|できるようになった。|できるという|可能な|できるので、|できて|でき、|可能である。|でき、また、|可能になる。" $file >needs_${file}
done
