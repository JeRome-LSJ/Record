
# 关于Redis中常用的命令总结：

> ## String
#### 自增命令和自减命令

命令  | 用法 | 描述
|----|---|---|
incr | incr key-name | 将键存储的值加上
decr | decr key-name | 将键存储的值减去1
incrby | incrby key-name amount | 将键存储的值加上整数amount
decrby | decrby key-name amount | 将键存储的值减去整数amount
incrbyfloat | incrbyfloat key-name amount | 将键存储的值加上浮点数amount(2.6版本及以上使用)

#### 供Redis处理子串和二进制位的命令
命令 | 用法 | 描述
|---|---|---|
|append | append key-name value | 将值value追加到给定键key-name当前存储的值的末尾|
|getrange | getrange key-name start end | 获取一个由偏移量start至偏移量end范围内所有字符组成的子串，包括start和end在内|
|setrange | setrange key-name offset value | 将从start偏移量开始的子串设置为给定值|
|getbit | getbit key-name offset | 将字节串看作是二进制位串(bit string)，并返回位串中偏移量为offset的二进制位的值|
|setbit | setbit key-name offset value | 将字节串看作是二进制位串，兵将位串中偏移量为offset的二进制位的值设置为value|
|bitcount | bitconunt key-name [start end] | 统计二进制位串里面值为1的二进制位的数量，如果给定了可选的start偏移量和end偏移量，那么只对偏移量指定范围内的二进制位进行统计|
|bitop | bitop operation dest-key key-name [key-name ...] | 对一个或者多个二进制位串执行包并(and)、或(or)、异或(xor)、非(not)在内的任意一种按位运算操作，并将计算得出的结果保存在dest-key键里面|

> ## 列表
#### 列表常用命令

命令 | 用法 | 描述
---|---|---
rpush | rpush key-name value [value ...] | 将一个或多个值推入列表的右端
lpush | lpush key-name value [value ...] | 将一个或多个值推入列表的左端
rpop | rpop key-name | 移除并返回列表最右端的元素
lpop | lpop key-name | 移除并返回列表最左端的元素
lindex | lindex key-name offset | 返回列表中偏移量为offset的元素
lrange | lrange key-name start end | 返回列表从start偏移量到end偏移量范围内的所有元素，其中偏移量为start和偏移量为end的元素也会包含在被返回的元素之内
ltrim | ltrim key-name start end | 队列表进行修剪，只保留从start偏移量到end偏移量范围内的元素，其中偏移量为start和偏移量为end额元素也会被保留

#### 阻塞式的列表弹出命令以及列表之间移动元素的命令

命令 | 用法 | 描述
---|---|---
|blpop | blpop key-name [key-name ...] timeout | 从第一个非空列表中弹出位于左端的元素，或者在timeout秒之内阻塞并等待可弹出的元素出现|
brpop | brpop key-name [key-name ...] timeout | 从第一个非空列表中弹出位于右端的元素，或者在timeout秒之内阻塞并等待可弹出的元素出现|
rpoplpush | rpoplpush source-key dest-key | 从source-key列表中弹出位于最右端的元素，然后将这个元素推入dest-key列表的最左端，并向用户返回这个元素
brpoplpush | brpoplpush source-key dest-key timeout | 从source-key列表中弹出位于最右端的元素，然后将这个元素推入dest-key列表的最左端，并向用户返回这个元素；如果source-key为空，那么在timeout秒之内阻塞并等待可弹出的元素出现
