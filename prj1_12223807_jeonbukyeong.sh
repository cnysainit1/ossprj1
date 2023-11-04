#! /bin/bash
stop="N"
line="------------------------------------"

month_arr=(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
month_int_arr=(01 02 03 04 05 06 07 08 09 10 11 12)
tmpfile=oss_prj_tmpfile

clear
echo $line
echo "User Name: `whoami`"
echo "Student Number: 12223807"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item'"
echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.item'"
echo "4. Delete the 'IMDb URL' from 'u.item'"
echo "5. Get the data about users from 'u.user'"
echo "6. Modify the format of 'release data' in 'u.item'"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo $line

until [ $stop = "Y" ]
do

	read -p "Enter your choice [ 1-9 ]: " choice
	case $choice in
	1)
		read -p "Please enter 'movie id' (1~1682): " movie_id
		cat $1 | awk -F\| -v a=$movie_id '$1==a {print $0}'
		;;
	2)
		read -p "Do you want to get the data of 'action' genre movies from 'u.item'? (y/n) " do_command
		if [ $do_command = "y" ]
		then
			cat $1 | awk -F\| '$7==1 {print $1, $2}' | head -n 10
		fi
		;;
	3)
		read -p "Please enter the 'movie id' (1~1682): " movie_id
		cat $2 | awk -v a=$movie_id '$2==a {cnt++; sum+=$3} END {printf"%.6g\n", sum/cnt}'
		;;
	4)
		read -p "Do you want to delete the 'IMDb URL' from 'u.item'? (y/n) " do_command
		if [ $do_command = "y" ]
		then
			cat $1 | sed -E 's/https?:\/\/[^|]*//' | head -n 10
		fi
		;;
	5)
		read -p "Do you want to get the data about users from 'u.user'? (y/n) " do_command
		if [ $do_command = "y" ]
		then
			cat $3 | sed -E -e 's/M/male/' -e 's/F/female/' -e 's/([0-9]+)\|([0-9]+)\|(male|female)\|([a-z]+).*/user \1 is \2 years old \3 \4/' | head -n 10
		fi
		;;
	6)
		read -p "Do you want to Modify the format of 'release data' in 'u.item'? (y/n)" do_command
		if [ $do_command = "y" ]
		then
			touch $tmpfile
			cat $1 > $tmpfile
			n=0
			while [ $n -lt 12 ]
			do
				sed -i -E "s/${month_arr[$n]}/${month_int_arr[$n]}/" $tmpfile
				n=$(( n+1 ))
			done
			cat $tmpfile | sed -E 's/([0-9]{2})-([0-9]{2})-([0-9]{4})/\3\2\1/' | tail -n 10
			rm $tmpfile
		fi
		;;
	7)
		touch $tmpfile
		read -p "Please enter the 'user id' (1~943): " user_id
		cat $2 | awk -v a=$user_id '$1==a {print $2}' | sort -n > $tmpfile
		cat $tmpfile | sed -zE 's/\n(.)/\|\1/g'
		echo
		awk -F\| 'NR==FNR {chker[$1]=1;next} chker[$1]==1 {print $1"|"$2}' $tmpfile $1 | head -n 10
		rm $tmpfile
		;;
	8)
		read -p "Do you want to get the average 'rating' of movies rated ny users with 'age' between 20 and 29 and 'occupation' as 'programmer'? (y/n): " do_command
		if [ $do_command = "y" ]
		then
			touch $tmpfile
			cat $3 | awk -F\| '$2>=20 && $2<=29 && $4=="programmer" {print $1}' > $tmpfile
			movie_entry_cnt=`wc -l < $1`
			n=0
			while [ $((n++)) -lt $movie_entry_cnt ]
			do
				awk -v idx=$n -v cnt=0 '
				NR==FNR {chker[$1]=1;next}
				chker[$1]==1 && $2==idx {sum+=$3; cnt++}
				END {if(cnt!=0) print idx, sum/cnt}' $tmpfile $2
			done
			rm $tmpfile
		fi
		;;
	9)
		echo Bye
		stop=Y
		;;	
	*)
		echo "wrong input"
		;;
	esac
done

exit 0
