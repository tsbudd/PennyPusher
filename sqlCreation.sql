#tables
create table expense(
	ex_id int primary key auto_increment,
    ex_amount numeric (6,2) not null,
    ex_item varchar (20) not null,
    ex_party varchar (20) not null,
    ex_date date not null,
    ex_type varchar(10) not null);
    
create table income(
	in_id int primary key auto_increment,
    in_amount numeric (6,2) not null,
    in_item varchar (20) not null,
    in_source varchar (20) not null,
    in_date date not null,
    in_type varchar(10));

create table account(
    acct_id int primary key auto_increment,
    acct_name varchar(20) not null,
    acct_value numeric (8,2) not null,
    acct_refresh_date date not null);

create table profit(
    profit_id int primary key auto_increment,
    profit_amount numeric (6,2),
    profit_date date,
    profit_time time);

create table paycheck(
    check_id int primary key auto_increment,
    income_id int not null,
    check_companyName varchar(20) not null,
    check_hours numeric(4,2) not null,
    check_startDate date not null,
    check_endDate date not null,
    check_payDate date not null,
    check_grossAmount numeric(6,2) not null,
    check_federalTax numeric(6,2),
    check_stateTax numeric(6,2),
    check_cityTax numeric(6,2),
    check_finalAmount numeric(6,2) not null,
    constraint fk_category
    foreign key (income_id) references income(in_id));

create table login_track(
    login_id int primary key auto_increment,
    login_date date not null,
    login_time time not null);

create table netWorth(
    worth_id int primary key auto_increment,
    worth_amount numeric (8,2) not null,
    worth_date date not null,
    worth_time time not null);

create table subscription(
    sub_id int primary key auto_increment,
    sub_item varchar(20) not null,
    sub_amount numeric (4,2) not null,
    sub_startDate date not null,
    sub_status enum('Active', 'Inactive') not null);

create table desiredPur(
    des_id int primary key auto_increment,
    des_item varchar(20) not null,
    des_amount numeric(6,2) not null,
    des_status enum('Not Purchased', 'Purchased', 'No Longer Interested') not null);

create table forSale(
    sale_id int primary key auto_increment,
    sale_item varchar(20) not null,
    sale_amount numeric(6,2) not null,
    sale_status enum('For Sale', 'Sold', 'No Longer Selling') not null);

ALTER TABLE expense AUTO_INCREMENT=1001;
ALTER TABLE income AUTO_INCREMENT=1001;
ALTER TABLE account AUTO_INCREMENT=1001;
ALTER TABLE profit AUTO_INCREMENT=1001;
ALTER TABLE paycheck AUTO_INCREMENT=1001;
ALTER TABLE login_track AUTO_INCREMENT=1001;
ALTER TABLE netWorth AUTO_INCREMENT=1001;
ALTER TABLE subscription AUTO_INCREMENT=1001;
ALTER TABLE desiredPur AUTO_INCREMENT=1001;
ALTER TABLE forSale AUTO_INCREMENT=1001;



delimiter //

#---------------------------------------------------------------------functions----------------------------------------------------------

create function getLastIncome()
    returns int
BEGIN
    declare income_id int;

    select max(in_id) into income_id
    from income;

return income_id;
end //

create function getProfitYear()
    returns numeric(8,2)
BEGIN
    declare moneyOut numeric(8,2);
    declare moneyIn numeric(8,2);

    select sum(ex_amount) into moneyOut
    from expense;

    select sum(in_amount) into moneyIn
    from income;

return moneyIn - moneyOut;
end //

create function getProfitMonth()
    returns numeric(8,2)
BEGIN
    declare moneyOut numeric(8,2);
    declare moneyIn numeric(8,2);

    select sum(ex_amount) into moneyOut
    from expense
    where month(expense.ex_date)= month(curdate())
    and year(expense.ex_date) = year(curdate());

    select sum(in_amount) into moneyIn
    from income
    where month(income.in_date) = month(curdate())
    and year(income.in_date) = year(curdate());

return moneyIn - moneyOut;
end //



#------------------------------------------------------------procedures------------------------------------------------------------


create procedure newLogin()
begin
    insert into login_track (login_date, login_time) values (curdate(), curtime());
end //

create procedure newExpense(amount numeric (6,2), item varchar(20), party varchar(20), day date, exType varchar(10))
BEGIN
    insert into expense (ex_amount, ex_item, ex_party, ex_date, ex_type) values (amount, item, party, day, exType);
    call updateProfit();
end //

create procedure newIncome(amount numeric (6,2), item varchar(20), source varchar(20), day date, inType varchar(10))
BEGIN
    insert into income(in_amount, in_item, in_source, in_date, in_type) values (amount, item, source, day, inType);
    call updateProfit();
end//

create procedure updateAccount(aname varchar(20), amount numeric(8,2))
BEGIN
    insert into account(acct_name, acct_value, acct_refresh_date) values (aname, amount, curdate());
end//

create procedure updateProfit()
BEGIN
    insert into profit(profit_amount, profit_date, profit_time) values (getProfitYear(), curdate(), curtime());
end//

create procedure newPaycheck(company varchar(20), hour numeric(4,2), startDate date, 
                endDate date, payDate date, gross numeric (6,2), federalTax numeric(6,2), 
                stateTax numeric(6,2), cityTax numeric(6,2), final numeric(6,2), inType varchar(10))
BEGIN
    insert into income(in_amount, in_item, in_source, in_date, in_type) values (final, "paycheck", company, payDate, inType);
    insert into paycheck(income_id, check_companyName, check_hours, check_startDate, 
                check_endDate, check_payDate, check_grossAmount, check_federalTax, 
                check_stateTax, check_cityTax, check_finalAmount)
        values (getLastIncome(), company, hour, startDate, endDate, payDate, gross, 
                federalTax, stateTax, cityTax, final);
end//


create procedure updateNetWorth()
BEGIN
    insert into netWorth(worth_amount, worth_date, worth_time) values (networth(), curdate(), curtime());
end //


create procedure newSubscription(item varchar(20), amount numeric(4,2), startD date)
BEGIN
    insert into subscription(sub_item, sub_amount, sub_startDate, sub_status)
        values (item, amount, startD, 'Active');
end //

create procedure updateSubscription(item varchar(20), amount numeric(4,2), Sstatus enum('Active', 'Inactive'))
BEGIN
    update subscription
    set sub_amount = amount,
    sub_status = Sstatus
    where sub_item = item;
end //

create procedure newDesiredPur(item varchar(20), amount numeric (6,2), Dstatus enum('Not Purchased', 'Purchased', 'No Longer Interested'))
BEGIN
    insert into desiredPur(des_item, des_amount, des_status)
        values (item, amount, Dstatus);
end //

create procedure updateDesiredPur(item varchar(20), amount numeric (6,2), Dstatus enum('Not Purchased', 'Purchased', 'No Longer Interested'))
BEGIN
    update desiredPur
    set des_amount = amount,
    des_status = Dstatus
    where des_item = item;
end //

create procedure newForSale(item varchar(20), amount numeric (6,2), Sstatus enum('For Sale', 'Sold', 'No Longer Selling'))
BEGIN
    insert into forSale (sale_item, sale_amount, sale_status)
        values (item, amount, Sstatus);
end //

create procedure updateForSale(item varchar(20), amount numeric (6,2), Sstatus enum('For Sale', 'Sold', 'No Longer Selling'))
BEGIN
    update forSale
    set sale_amount = amount,
    sale_status = Sstatus
    where sale_item = item;
end //

create procedure netWorth()
begin
	select a1.acct_value, a1.acct_name, a1.acct_refresh_date
            from (select distinct a0.acct_name, a0.acct_value, a0.acct_id, a0.acct_refresh_date
                    from account as a0
                    order by acct_id desc) a1
            group by a1.acct_name;
end //

delimiter ;

#test cases
call newIncome(350.00, "rent", "Mom", "2021-11-01", "Housing");
call newExpense(49.99, "drive hub", "best buy", "2021-11-15", "Technology");
call newPaycheck("OAP", 40.5, "2021-11-01", "2021-11-14", 
                "2021-11-21", 581.25, 12.00, 5.21, 0.00, 564.04, "Paycheck");
call newLogin();
delete from account where acct_id > 1;
call updateAccount("Bank Account Spend", 2123.56);
call updateAccount("Bank Account Reserve", 3000.00);
call updateAccount("Bank Account Growth", 2155.50);
call updateAccount("Investments", 6650.45);
call newSubscription("Spotify", 4.99, "2021-11-15");

select max(login_id), login_date, login_time from login_track;
delete from login_track where login_id > 1;
ALTER TABLE login_track AUTO_INCREMENT=1001;
select * from account;
select * from netWorth;
select * from subscription;
delete from subscription where sub_id > 1;
delete from desiredPur where des_id > 1;
call updatenetWorth();
show procedure status;
call newDesiredPur("Laptop", 1200.59, "Not Purchased");
select * from forSale;
insert into forSale(sale_item, sale_amount, sale_status) values ("bike", 250.49, "For Sale");


select a2.acct_name, a2.acct_value, a2.acct_refresh_date
    from (select a1.acct_value, a1.acct_name, a1.acct_refresh_date
            from (select distinct a0.acct_name, a0.acct_value, a0.acct_id, a0.acct_refresh_date
                    from account as a0
                    order by acct_id desc) a1
            group by a1.acct_name) a2;
select distinct acct_name, acct_value
	from account
    order by acct_id desc;

select * from account;

select sum(a2.acct_value)
	from(
	select a1.acct_value, a1.acct_name, a1.acct_refresh_date
            from (select distinct a0.acct_name, a0.acct_value, a0.acct_id, a0.acct_refresh_date
                    from account as a0
                    order by acct_id desc) a1
            group by a1.acct_name) a2;
select * from expense;