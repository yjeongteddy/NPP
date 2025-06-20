#find ./ -name "*.tar" -exec bash -c "echo {} > temp" \; \
#                      -exec bash -c "echo {} | sed 's/^.pgbh06.//' | sed 's/.tar//' >> temp" \; \
#                      -exec bash -c "cat temp | xargs -n2 -I{} tar -xvf {} --wildcards --no-anchored '*pgbh06*' --transform='s,^,{},'" \;
#                       -exec bash -c "cat temp | xargs -n1 -I {} tar -xvf $1 --wildcards --no-anchored '*pgrbh06*' --transform='s,^,$2,'" \;
#                       -exec bash -c "echo {} `cat temp` | xargs -n 3 echo $1 _ $2" \;

#                       -exec bash -c "echo {} `cat temp` | xargs -n2 -I{} tar -xvf $1 --wildcards --no-anchored '*pgrbh06*' --transform='s,^,$2,'" \; \
#                       -exec bash -c "echo {} `cat temp` | xargs -n1 -I{}  tar -xvf $0 --wildcards --no-anchored '*pgrbh06*' --transform='s,^,$1,'" \; \
#                       -exec bash -c "cat temp | xargs -n1 -I{} echo {}" \; 

#                       -exec bash -c "cat temp" \;  \
#                       -exec bash -c "ls cdas1*.grib2 | xargs -i $ echo $1" \; \




#                       -exec bash -c "xargs --arg-file=temp rename cdas1 $1 cdas1*.grib2" \; \
#                       -exec bash -c "find ./ -name 'cdas1*.grib2' -exec echo {}  \;" \; \
#                       -exec bash -c "cat temp" \; 
rename cdas1 `cat temp`.cdas1 cdas1*.grib2" \; \
                       -exec bash -c "cat temp | xargs -i rename cdas1 .cdas1 cdas1*.grib2" \; \
                       -exec bash -c "cat temp | xargs echo {}_TEST" \; \
                       -exec bash -c "cat temp" \; \
                       -exec bash -c "echo {}" \; \
                       -exec bash -c 'export TEST={}' \; \
                       -exec echo $TEST \;
                       -exec echo {} \; | sed 's/^.*cdas1.//' | sed 's/.pgrbh.tar//' | xargs -i echo {}
rename cdas1 {}.cdas1 cdas1*.grib2 \; \

# find ./ -name "*.tar" -exec tar -xvf {} --wildcards --no-anchored '*pgrbh06*' \; \
#                       -exec bash -c "echo {} | sed 's/^.*cdas1.//' | sed 's/.pgrbh.tar//' > temp" \; \
#                       -exec bash -c "rename cdas1 $(cat temp).cdas1 cdas1*.grib2" \;
# rename cdas1 `cat temp`.cdas1 cdas1*.grib2
