---
title: "Spark DataFrame - two ways to count the number of rows per partition"
date: 2020-08-15T00:00:00+01:00
tags: ['spark', 'howto']
---

Sometimes, we are required to compute the number of rows per each partition. To do this, there are two ways: 

* The first way is using ```Dataframe.mapPartitions()```.

* The second way (the faster according to my observations) is using the ```spark_partition_id()``` function, followed by a grouping count aggregation.


## Let's first load the data into a dataframe  

*I have used the SF Bay Area Bike data source, that can be found [**here**](https://www.kaggle.com/benhamner/sf-bay-area-bike-share/data#)*

Scala : 

```scala
val df = spark.read.csv("file:///.../status.csv")
```


## Method 1 - using mapPartitions()
Scala : 
```scala
val countByPartition1 = 
       df.mapPartitions(iter => Array(iter.size).iterator)
         .collect()
```

* ```DataFrame.mapPartitions``` : takes as parameter a lambda function that takes an iterator, and returns another iterator. 

* It will create for each partition an iterator and will then pass it to the lambda function and finally will return a dataset that combines the results of the lambda function. 

* Our lambda function is returning a single element iterator that contains the size of the input iterator (which is the number of rows in the partition). 

The final result will be an array that contains the size of each partition, where the index of the array is the partition ID :  
   
```
countByPartition1: Array[Int] = Array(4949155, 4863123, 4796844, 4910927, 4864103, 4848557, 4790660, 4985291, 4858505, 4853698, 4874157, 4814367, 4805210, 4790091, 3979746)
```

## Method 2 - using spark_partition_id()

Scala : 
```scala
val countByPartition2 = df.groupBy(spark_partition_id())
                          .count()
                          .collect() 
```

* ```spark_partition_id()``` is a non deterministic function that returns a Column expression that generates for each row the ID of its corresponding partition.
* We group the dataframe by this column, and apply a count aggregation, which gives a new dataframe with two columns : Partition ID + Count of rows.


```
countByPartition2: Array[org.apache.spark.sql.Row] = Array([12,4805210], [1,4863123], [13,4790091], [6,4790660], [3,4910927], [5,4848557], [9,4853698], [4,4864103], [8,4858505], [7,4985291], [10,4874157], [11,4814367], [14,3979746], [2,4796844], [0,4949155])
```

## Conclusion 

You can go either way to compute the number of rows per partition.
However, I've noticed that the second method can be up to 5 times faster than the first method.

This can be useful to find and resolve performance issues related to data skewness. 