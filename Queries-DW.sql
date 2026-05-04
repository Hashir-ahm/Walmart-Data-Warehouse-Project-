use abcd_dw;

-- q1: top revenue-generating products on weekdays and weekends with monthly drill-down
with rankedproducts as (
    select 
        p.product_id,
        p.product_category,
        t.month,
        t.year,
        case when t.is_weekend then 'weekend' else 'weekday' end as day_type,
        sum(fs.total_amount) as total_revenue,
        rank() over (partition by t.month, case when t.is_weekend then 'weekend' else 'weekday' end order by sum(fs.total_amount) desc) as revenue_rank
    from factsales fs
    join dimproduct p on fs.product_key = p.product_key
    join dimtime t on fs.time_key = t.time_key
    where t.year = 2020
    group by p.product_id, p.product_category, t.month, t.year, t.is_weekend
)
select 
    product_id,
    product_category,
    month,
    year,
    day_type,
    total_revenue,
    revenue_rank
from rankedproducts
where revenue_rank <= 5
order by year, month, day_type, revenue_rank;

-- q2: customer demographics by purchase amount with city category breakdown
select 
    c.gender,
    c.age_group,
    c.city_category,
    sum(fs.total_amount) as total_purchase_amount,
    count(distinct fs.order_id) as total_orders,
    avg(fs.total_amount) as avg_order_value
from factsales fs
join dimcustomer c on fs.customer_key = c.customer_key
group by c.gender, c.age_group, c.city_category
order by total_purchase_amount desc;

-- q3: product category sales by occupation
select 
    p.product_category,
    c.occupation,
    sum(fs.total_amount) as total_sales,
    count(fs.order_id) as total_orders
from factsales fs
join dimproduct p on fs.product_key = p.product_key
join dimcustomer c on fs.customer_key = c.customer_key
group by p.product_category, c.occupation
order by p.product_category, total_sales desc;

-- q4: total purchases by gender and age group with quarterly trend
select 
    c.gender,
    c.age_group,
    t.quarter,
    t.year,
    sum(fs.total_amount) as quarterly_purchases,
    lag(sum(fs.total_amount)) over (partition by c.gender, c.age_group order by t.year, t.quarter) as prev_quarter_purchases
from factsales fs
join dimcustomer c on fs.customer_key = c.customer_key
join dimtime t on fs.time_key = t.time_key
where t.year = 2020
group by c.gender, c.age_group, t.quarter, t.year
order by c.gender, c.age_group, t.year, t.quarter;

-- q5: top occupations by product category sales
with rankedoccupations as (
    select 
        p.product_category,
        c.occupation,
        sum(fs.total_amount) as total_sales,
        rank() over (partition by p.product_category order by sum(fs.total_amount) desc) as occupation_rank
    from factsales fs
    join dimproduct p on fs.product_key = p.product_key
    join dimcustomer c on fs.customer_key = c.customer_key
    group by p.product_category, c.occupation
)
select * from rankedoccupations
where occupation_rank <= 5
order by product_category, occupation_rank;

-- q6: city category performance by marital status with monthly breakdown (last 6 months)
select 
    c.city_category,
    c.marital_status,
    t.month,
    t.year,
    sum(fs.total_amount) as monthly_sales,
    count(fs.order_id) as order_count
from factsales fs
join dimcustomer c on fs.customer_key = c.customer_key
join dimtime t on fs.time_key = t.time_key
where t.full_date >= date_sub((select max(full_date) from dimtime), interval 6 month)
group by c.city_category, c.marital_status, t.month, t.year
order by t.year, t.month, c.city_category;

-- q7: average purchase amount by stay duration and gender
select 
    c.stay_in_current_city_years,
    c.gender,
    avg(fs.total_amount) as avg_purchase_amount,
    count(fs.order_id) as total_orders
from factsales fs
join dimcustomer c on fs.customer_key = c.customer_key
group by c.stay_in_current_city_years, c.gender
order by c.stay_in_current_city_years, c.gender;

-- q8: top 5 revenue-generating cities by product category
with rankedcities as (
    select 
        c.city_category,
        p.product_category,
        sum(fs.total_amount) as total_revenue,
        rank() over (partition by p.product_category order by sum(fs.total_amount) desc) as city_rank
    from factsales fs
    join dimcustomer c on fs.customer_key = c.customer_key
    join dimproduct p on fs.product_key = p.product_key
    group by c.city_category, p.product_category
)
select * from rankedcities
where city_rank <= 5
order by product_category, city_rank;

-- q9: monthly sales growth by product category
with monthly_sales as (
    select 
        p.product_category,
        t.year,
        t.month,
        sum(fs.total_amount) as monthly_sales,
        lag(sum(fs.total_amount)) over (partition by p.product_category order by t.year, t.month) as prev_month_sales
    from factsales fs
    join dimproduct p on fs.product_key = p.product_key
    join dimtime t on fs.time_key = t.time_key
    where t.year = 2020
    group by p.product_category, t.year, t.month
)
select 
    product_category,
    year,
    month,
    monthly_sales,
    prev_month_sales,
    case 
        when prev_month_sales is null then null
        else round(((monthly_sales - prev_month_sales) / prev_month_sales) * 100, 2)
    end as growth_percentage
from monthly_sales
order by product_category, year, month;

-- q10: weekend vs. weekday sales by age group
select 
    c.age_group,
    case when t.is_weekend then 'weekend' else 'weekday' end as day_type,
    sum(fs.total_amount) as total_sales,
    count(fs.order_id) as total_orders
from factsales fs
join dimcustomer c on fs.customer_key = c.customer_key
join dimtime t on fs.time_key = t.time_key
where t.year = 2020
group by c.age_group, day_type
order by c.age_group, day_type;

-- q11: top revenue-generating products on weekdays and weekends with monthly drill-down
with rankedproducts as (
    select 
        p.product_id,
        p.product_category,
        t.month,
        t.year,
        case when t.is_weekend then 'weekend' else 'weekday' end as day_type,
        sum(fs.total_amount) as total_revenue,
        rank() over (partition by t.month, case when t.is_weekend then 'weekend' else 'weekday' end order by sum(fs.total_amount) desc) as revenue_rank
    from factsales fs
    join dimproduct p on fs.product_key = p.product_key
    join dimtime t on fs.time_key = t.time_key
    where t.year = 2020
    group by p.product_id, p.product_category, t.month, t.year, t.is_weekend
)
select * from rankedproducts
where revenue_rank <= 5
order by year, month, day_type, revenue_rank;

-- q12: trend analysis of store revenue growth rate quarterly for 2017
with quarterly_sales as (
    select 
        s.store_name,
        t.year,
        t.quarter,
        sum(fs.total_amount) as quarterly_revenue,
        lag(sum(fs.total_amount)) over (partition by s.store_name order by t.year, t.quarter) as prev_quarter_revenue
    from factsales fs
    join dimstore s on fs.store_key = s.store_key
    join dimtime t on fs.time_key = t.time_key
    where t.year = 2017
    group by s.store_name, t.year, t.quarter
)
select 
    store_name,
    year,
    quarter,
    quarterly_revenue,
    prev_quarter_revenue,
    case 
        when prev_quarter_revenue is null then null
        else round(((quarterly_revenue - prev_quarter_revenue) / prev_quarter_revenue) * 100, 2)
    end as growth_rate
from quarterly_sales
order by store_name, year, quarter;

-- q13: detailed supplier sales contribution by store and product name
select 
    s.store_name,
    s.supplier_name,
    p.product_id as product_name,
    p.product_category,
    sum(fs.total_amount) as total_sales,
    count(fs.order_id) as order_count
from factsales fs
join dimstore s on fs.store_key = s.store_key
join dimproduct p on fs.product_key = p.product_key
group by s.store_name, s.supplier_name, p.product_id, p.product_category
order by s.store_name, s.supplier_name, total_sales desc;

-- q14: seasonal analysis of product sales using dynamic drill-down
select 
    p.product_id,
    p.product_category,
    case 
        when t.month in (3,4,5) then 'spring'
        when t.month in (6,7,8) then 'summer'
        when t.month in (9,10,11) then 'fall'
        else 'winter'
    end as season,
    sum(fs.total_amount) as seasonal_sales,
    count(fs.order_id) as order_count
from factsales fs
join dimproduct p on fs.product_key = p.product_key
join dimtime t on fs.time_key = t.time_key
group by p.product_id, p.product_category, season
order by p.product_id, season;

-- q15: store-wise and supplier-wise monthly revenue volatility
with monthly_revenue as (
    select 
        s.store_name,
        s.supplier_name,
        t.year,
        t.month,
        sum(fs.total_amount) as monthly_revenue,
        lag(sum(fs.total_amount)) over (partition by s.store_name, s.supplier_name order by t.year, t.month) as prev_month_revenue
    from factsales fs
    join dimstore s on fs.store_key = s.store_key
    join dimtime t on fs.time_key = t.time_key
    group by s.store_name, s.supplier_name, t.year, t.month
)
select 
    store_name,
    supplier_name,
    year,
    month,
    monthly_revenue,
    prev_month_revenue,
    case 
        when prev_month_revenue is null then null
        else round(((monthly_revenue - prev_month_revenue) / prev_month_revenue) * 100, 2)
    end as volatility_percentage
from monthly_revenue
order by abs(volatility_percentage) desc;

-- q16: robust product affinity analysis
with multiproductorders as (
    select 
        order_id,
        count(distinct product_key) as product_count
    from factsales 
    group by order_id 
    having count(distinct product_key) > 1
),
orderproducts as (
    select 
        fs.order_id,
        p.product_id,
        p.product_category
    from factsales fs
    join dimproduct p on fs.product_key = p.product_key
    where fs.order_id in (select order_id from multiproductorders)
),
productpairs as (
    select distinct
        op1.order_id,
        least(op1.product_id, op2.product_id) as product1,
        (case when op1.product_id < op2.product_id then op1.product_category else op2.product_category end) as product1_category,
        greatest(op1.product_id, op2.product_id) as product2,
        (case when op1.product_id > op2.product_id then op1.product_category else op2.product_category end) as product2_category
    from orderproducts op1
    join orderproducts op2 on op1.order_id = op2.order_id
    where op1.product_id != op2.product_id
),
paircounts as (
    select 
        product1,
        product1_category,
        product2,
        product2_category,
        count(distinct order_id) as pair_count
    from productpairs
    group by product1, product1_category, product2, product2_category
)
select 
    product1,
    product1_category,
    product2,
    product2_category,
    pair_count,
    rank() over (order by pair_count desc) as affinity_rank
from paircounts
order by pair_count desc
limit 5;

-- q17: yearly revenue trends by store, supplier, and product with rollup
select 
    coalesce(s.store_name, 'all stores') as store_name,
    coalesce(s.supplier_name, 'all suppliers') as supplier_name,
    coalesce(p.product_category, 'all products') as product_category,
    t.year,
    sum(fs.total_amount) as total_revenue
from factsales fs
join dimstore s on fs.store_key = s.store_key
join dimproduct p on fs.product_key = p.product_key
join dimtime t on fs.time_key = t.time_key
group by s.store_name, s.supplier_name, p.product_category, t.year with rollup
having store_name is not null
order by store_name, supplier_name, product_category, year;

-- q18: revenue and volume-based sales analysis for each product for h1 and h2
with producthalfyearly as (
    select 
        p.product_id,
        p.product_category,
        case when t.month <= 6 then 'h1' else 'h2' end as half_year,
        sum(fs.total_amount) as half_year_revenue,
        sum(fs.quantity) as half_year_quantity,
        count(fs.order_id) as half_year_orders
    from factsales fs
    join dimproduct p on fs.product_key = p.product_key
    join dimtime t on fs.time_key = t.time_key
    where t.year = 2020
    group by p.product_id, p.product_category, half_year
),
productyearly as (
    select 
        p.product_id,
        p.product_category,
        'year' as half_year,
        sum(fs.total_amount) as half_year_revenue,
        sum(fs.quantity) as half_year_quantity,
        count(fs.order_id) as half_year_orders
    from factsales fs
    join dimproduct p on fs.product_key = p.product_key
    join dimtime t on fs.time_key = t.time_key
    where t.year = 2020
    group by p.product_id, p.product_category
)
select * from producthalfyearly
union all
select * from productyearly
order by product_id, half_year;

-- q19: identify high revenue spikes in product sales and highlight outliers
with product_daily_sales as (
    select 
        p.product_id,
        p.product_category,
        t.full_date,
        sum(fs.total_amount) as daily_sales,
        avg(sum(fs.total_amount)) over (partition by p.product_id) as avg_daily_sales
    from factsales fs
    join dimproduct p on fs.product_key = p.product_key
    join dimtime t on fs.time_key = t.time_key
    group by p.product_id, p.product_category, t.full_date
),
spikes as (
    select 
        product_id,
        product_category,
        full_date,
        daily_sales,
        avg_daily_sales,
        case when daily_sales > 2 * avg_daily_sales then 'spike' else 'normal' end as sales_status,
        round(((daily_sales - avg_daily_sales) / avg_daily_sales) * 100, 2) as percentage_above_avg
    from product_daily_sales
    where daily_sales > 2 * avg_daily_sales
)
select 
    product_id,
    product_category,
    full_date,
    daily_sales,
    avg_daily_sales,
    sales_status,
    percentage_above_avg,
    case 
        when month(full_date) = 12 and percentage_above_avg > 100 then 'holiday season peak'
        when percentage_above_avg > 200 then 'major promotional event or data error'
        when percentage_above_avg between 100 and 200 then 'seasonal demand spike'
        else 'moderate sales increase'
    end as anomaly_explanation
from spikes
order by (daily_sales - avg_daily_sales) desc;

-- q20: create view for optimized sales analysis
create or replace view store_quarterly_sales as
select 
    s.store_name,
    t.year,
    t.quarter,
    sum(fs.total_amount) as quarterly_sales,
    count(distinct fs.order_id) as order_count,
    avg(fs.total_amount) as avg_order_value
from factsales fs
join dimstore s on fs.store_key = s.store_key
join dimtime t on fs.time_key = t.time_key
group by s.store_name, t.year, t.quarter
order by s.store_name, t.year, t.quarter;