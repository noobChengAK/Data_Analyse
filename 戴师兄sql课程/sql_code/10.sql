-- 我想看去年第一季度下单人数前3的门店，业绩表现如何
select
品牌名称
,门店名称
,sum(GMV) 累计GMV
,sum(下单人数)累计下单人数
,sum(曝光人数)累计曝光人数
,sum(进店人数)累计进店人数
from ddm.shop
where 日期 between '2020-01-01' and '2020-03-31'
group by 1,2
order by sum(下单人数) desc
limit 3




-- 去年第一季度每个月，每个门店的累计GMV
select
品牌名称
,门店名称

,sum(GMV) 累计GMV
,substring(日期, 1,7)月份
from ddm.shop
where 日期 between '2020-01-01' and '2020-03-31'
group by 1,2,3
order by 品牌名称,门店名称,月份

-- 去年第一季度曝光人数大于10w的门店，每个月的GMV

select
品牌名称
,门店名称
,substring(日期, 1,7)月份
,sum(GMV) 累计GMV
from ddm.shop
where 日期 between '2020-01-01' and '2020-03-31'
group by 1,2
having sum(曝光人数 > 100000)





-- 所有门店20年7月的累计GMV、累计CPC、累计商家实收、累计用户实付
select
shop.门店名称
,sum(shop.GMV) 累计GMV
,sum(cpc.cpc总费用) 累计CPC
,sum(shop.商家实收) 累计商家实收
,sum(用户实付) 累计用户实付
from ddm.shop shop
left join ddm.cpc cpc on shop.门店ID = cpc.门店ID and shop.日期 = cpc.日期
left join(
			select
			门店ID
			,下单日期
			,sum(用户实付) 用户实付)
			from ods.orders
			group by 1,2
		) ord on shop.门店ID = ord.门店ID and shop.日期 == ord.下单日期
where substring(shop.日期,1,7) = '2020-07'
group by 1



-- 代码优化


select 
shop.门店名称
,sum(shop.GMV) 累计GMV
,sum(cpc.cpc总费用) 累计CPC
,sum(shop.商家实收) 累计商家实收
,sum(用户实付) 累计用户实付
from ddm.shop shop
left join ddm.cpc cpc on shop.门店ID and shop.日期 = cpc.日期 and substring(cpc.日期,1,7) = '2020-07'
left join (
			select
			门店ID
			,下单日期
			,sum(用户实付)用户实付
			from ods.orders
			where substring(下单日期,1,7) = '2020-07'
			group by 1,2
			) ord on shop.门店ID = ord.门店ID and shop.日期 = ord.下单日期
where substring(shop.日期,1,7) = '2020-07'
group by 1




-- 拌客在饿了么上20年第二季度每个月的GMV，以及每个月GMV在第四季度累计GMV的占比

select 
a.品牌名称
,a.月份
,a.当月GMV
,b.季度GMV
,concat(round((a.当月GMV/b.季度GMV)*100,0),'%') 占比





-- 9、2020年拌客和蛙小辣两个品牌在饿了么和美团两个平台上各自GMV最高的3天以及这三天的GMV




-- 2020年拌客和蛙小辣两个品牌在饿了么和美团两个平台上，GMV不为零的日子里，GMV的极差

select
     品牌名称
     ,平台
     ,avg(GMV最大值 - GMV最小值)GMV极差
     from(
     
         select
        	品牌名称
         ,平台
         ,日期
         ,GMV
         ,first_value(GMV) over(partition by 品牌名称,平台 order by GMV desc) GMV最大值
         ,first_value(GMV) over(partition by 品牌名称,平台 order by GMV) GMV最小值
         from ddm.shop
         where substring(日期,1,4) = '2020'
         and (品牌名称 like '%蛙小辣%' or 品牌名称 like '%拌客%')
         and GMV > 0
     ) a
     group by 1,2


-- 2020年拌客和蛙小辣两个品牌各自门店在饿了么GMV排名前5%（GMV为0不计入排名）的日期、GMV、以及具体排名及排名百分比（取一位小数）




-- 2020年拌客在双平台每日GMV及前一日GMV，及GMV周同比增长绝对值（差异值）与百分比




