use oocsv
import structs/ArrayList
import io/[FileReader,FileWriter]

allNum : func(data : String) -> Bool
{
    for(i in 0 .. data size)
    {
        if(data[i] != '0' && data[i] != '1' && data[i] != '2' && data[i] != '3' && data[i] != '4' && data[i] != '5' && data[i] != '6' && data[i] != '7' && data[i] != '8' && data[i] != '9')
        {
            return false
        }
    }
    true
}

Field : class
{
    data : String
    init : func(=data)
    {
    }
}

// Improve operators to support Int's (44 > 5 xD)

operator > (left, right: Field) -> Bool 
{
    data1 := left data
    data2 := right data
    if(allNum(data1) && allNum(data2))
    {
        return data1 toInt() > data2 toInt()
    }
    for(i in 0 .. data1 size)
    {
        if(data1[i] as Int > data2[i] as Int)
        {
            return true
        }
        else if(data1[i] as Int < data2[i] as Int)
        {
            return false
        }
    }
    false
}

operator < (left, right: Field) -> Bool 
{
    data1 := left data
    data2 := right data
    if(allNum(data1) && allNum(data2))
    {
        return data1 toInt() < data2 toInt()
    }
    for(i in 0 .. data1 size)
    {
        if(data1[i] as Int < data2[i] as Int)
        {
            return true
        }
        else if(data1[i] as Int > data2[i] as Int)
        {
            return false
        }
    }
    false
}

Column : class
{
    name: String
    fields := ArrayList<Field> new()
    init : func(=name)
    {
    }
    addField : func ~withdata (data : String)
    {
        fields ensureCapacity(fields size+1)
        fields add(Field new(data))
    }
    addField : func ~withfield (field : Field)
    {
        fields ensureCapacity(fields size+1)
        fields add(field)
    }
    getField : func ~withdata (fieldData : String) -> Field
    {
        for(i in 0 .. fields size)
        {
            if(fields get(i) data == fieldData)
            {
                return fields get(i)
            }
        }
        null
    }
    selectField : func ~withindex (index : Int) -> Field
    {
        fields get(index)
    }
    deleteField : func ~withdata (fieldData : String)
    {
        fields remove(getField(fieldData))
    }
    deleteField : func ~withindex (index : Int)
    {
        fields removeAt(index)
    }
}

Database : class
{
    columns := ArrayList<Column> new()
    file : String
    freader : FileReader
    init : func ~empty () 
    {
        // Just a default constructor, in case you want to build a database from scratch, not import it from a file
    }
    init : func ~withfile (=file)
    {
        inField := false
        data : String
        temp : String
        freader = FileReader new(file)
        columnIndex := 0
        lineIndex := 0
        while(freader hasNext?())
        {
            data = (data == null) ? freader read() as String : data + freader read() as String
        }
        freader close()
        for(i in 0 .. data size)
        {
            if((data[i] == ',' || i == data size-1 || data[i] == '\n' || data[i] == '\r') && !inField && temp != "")
            {
                // store data to column
                if(lineIndex == 0)
                {
                    columns ensureCapacity(columns size+1)
                    columns add(Column new(temp))
                }
                else
                {
                    columns[columnIndex] addField(temp)
                }
                temp = ""
                columnIndex += 1
                if(data[i] == '\n' || data[i] == '\r')
                { 
                    lineIndex += 1
                    columnIndex = 0
                }
            }
            else if(data[i] == '"' && data[i-1] != '\\')
            {
                inField = !inField
            }
            else if(data[i] != '\r' && data[i] != '\n')
            {
                temp = (temp == null) ? data[i] as String : temp + data[i] as String
            }
        }
    }
    
    columnIndexFromName : func(columnName : String) -> Int
    {
        for(i in 0 .. columns size)
        {
            if(columns get(i) name == columnName)
            {
                return i
            }
        }
        -1
    }
    
    selectColumn : func ~withindex (columnIndex : Int) -> Column
    {
        columns get(columnIndex)
    }
    
    selectColumn : func ~withname (columnName : String) -> Column
    {
        selectColumn(columnIndexFromName(columnName))
    }
    
    deleteColumn : func ~withname (columnName : String)
    {
        deleteColumn(columnIndexFromName(columnName))
    }
    
    deleteColumn : func ~withindex (columnIndex : Int)
    {
        columns removeAt(columnIndex)
    }
    
    addLine : func ~withdatas (values : ArrayList<String>) -> Bool
    {
        if(values size != columns size)
        {
            return false
        }
        for(i in 0 .. values size)
        {
            columns get(i) addField(values get(i))
        }
        true
    }
    
    addLine : func ~withfields (values : ArrayList<Field>) -> Bool
    {
        if(values size != columns size)
        {
            return false
        }
        for(i in 0 .. values size)
        {
            columns get(i) addField(values get(i))
        }
        true
    }
    
    addColumn : func(column : Column)
    {
        columns ensureCapacity(columns size+1)
        columns add(column)
    }
    // order : 0 .. 9 , A .. Z, a .. z
    sortAscending : func ~withindex (columnIndex: Int)
    {
        // sort selected column
        i := columns get(columnIndex) fields size-1
        while(i >= 0)
        {
            for(j in 1 .. i)
            {
                if(columns get(columnIndex) fields get(j-1) > columns get(columnIndex) fields get(j)) 
                {
                    swapLines(j-1,j)
                }
            }
            i -= 1
        }

    }
    
    sortAscending : func ~withname (columnName : String)
    {
        sortAscending(columnIndexFromName(columnName))
    }
    
    sortDescending : func ~withindex (columnIndex: Int)
    {
        // sort selected column
        i := columns get(columnIndex) fields size-1
        while(i >= 0)
        {
            for(j in 1 .. i+1)
            {
                if(columns get(columnIndex) fields get(j-1) < columns get(columnIndex) fields get(j)) 
                {
                    swapLines(j-1,j)
                }
            }
            i -= 1
        }
    
    }
    
    sortDescending : func ~withname (columnName : String)
    {
        sortDescending(columnIndexFromName(columnName))
    }
    
    swapLines : func(index1,index2: Int) // swap two lines
    {
        for(i in 0 .. columns size)
        {
            temp := columns[i] fields[index1] // temporarily stock one of the two fields to swap
            columns[i] fields[index1] = columns get(i) fields get(index2)// swap! =D
            columns[i] fields[index2] = temp
        }
    }
    
    swapColumns : func ~withindex (index1,index2: Int) // swap two columns
    {
        temp := columns get(index1)
        columns[index1] = columns get(index2)
        columns[index2] = temp
    }
    
    swapColumns : func ~withname (name1,name2 : String)
    {
        swapColumns(columnIndexFromName(name1),columnIndexFromName(name2))
    }
    
    deleteLine : func(index : Int)
    {
        for(i in 0 .. columns size)
        {
            columns[i] deleteField(index)
        }
    }
    
    save : func ~empty ()
    {
        save(file)
    }
    save : func ~withfile (sfile : String)
    {
        saveStr : String
        for(i in 0 .. columns size)
        {
            saveStr = (saveStr == null) ? "\""+columns get(i) name+"\"" : saveStr+","+"\""+columns get(i) name+"\"" // write headers
        }
        saveStr += "\n"
    
        for(i in 0 .. columns get(0) fields size)
        {
            for(j in 0 .. columns size)
            {
                separator := (j == columns size-1) ? "\n" : ","
                saveStr += "\""+columns get(j) fields get(i) data+"\""+separator
            }
        }
        fwriter := FileWriter new(sfile)
        fwriter write(saveStr _buffer data,saveStr _buffer size)
        fwriter close()
    }
}