use oocsv
import oocsv

main : func -> Int
{
    db := Database new("test.csv") // open test.csv database
    println("ID -> POST")
    ids := db selectColumn("id") fields // get id fields
    posts := db selectColumn("post") fields // get post fields
    for(i in 0 .. ids size)
    {
        println(ids get(i) data+" -> "+posts get(i) data)// print data
    }
    
    println("Test2 :D")
    line := db selectLine("id","0") // select line with id 0 ;)
    for(i in 0 .. line size)
    {
        println(line get(i) data) // orint all line's fields (expected output : 0\nhehe
    }
    
    db sortDescending("id") // sort database on descending order based on id column(equivalent to db sortDescending(0) in this case)
    db save("test2.csv") // save sorted database to a new file! :)
    0
}