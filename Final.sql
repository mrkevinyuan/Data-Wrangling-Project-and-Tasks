drop table [kyuan].[final]
drop table [kyuan].[tot]
drop table [kyuan].[f]
select * into kyuan.final from [kyuan].[ICBP]
select * from kyuan.final

--1a 
alter table [kyuan].[final] add BPstatus int;
-- Create the table BP status for future use

--1b
update [kyuan].[final] set [BPstatus] = '1' where [BPAlerts] = 'Hypo1'
update [kyuan].[final] set [BPstatus] = '1' where [BPAlerts] = 'Normal'
update [kyuan].[final] set [BPstatus] = '0' where [BPAlerts] = 'HTN1'
update [kyuan].[final] set [BPstatus] = '0' where [BPAlerts] = 'HTN2'
update [kyuan].[final] set [BPstatus] = '0' where [BPAlerts] = 'HTN3'
update [kyuan].[final] set [BPstatus] = '0' where [BPAlerts] = 'Hypo2'
-- Setting the status of BP to desirable binary number 0,1 to determine each specific BP Status 

--1c
select * into kyuan.tot from [kyuan].[final]
inner join [dbo].[Demographics] on [dbo].[Demographics].[contactid] = [kyuan].[final].[ID]
--Merge the table with demographics.

--1d
alter table [kyuan].[tot] add dweek int
update [kyuan].[tot] set [dweek] = DATEDIFF(WEEK,TRY_CONVERT(datetime2,[kyuan].[tot].tri_enrollmentcompletedate) , [ObservedTime])
select [ID], [ObservedTime], TRY_CONVERT(datetime2,[kyuan].[tot].tri_enrollmentcompletedate), dweek from [kyuan].[final] where dweek <= 12 and dweek >= 0 order by [ID] ,  [ObservedTime]
select [ID],[dweek], AVG([BPstatus]) as BPAve from (select * from [kyuan].[tot] where [dweek]<= 12 and [dweek]>= 0) T group by [ID], [dweek] order by [ID], [dweek]
--create the 12-week interval of averaged score of each customer

--1e
select fw.ID, fw.fwave, tw.twstatus from 
(select [ID], AVG([BPstatus]) as fwave from [kyuan].[tot] where [dweek] = 0 group by [ID]) fw
inner join
(select [ID], AVG([BPstatus]) as twstatus from [kyuan].[tot] where [dweek] = 12 group by [ID]) tw on fw.ID = tw.ID
--comparing the scores from 1 week to 12 week

--1f
--2 customers were brought from uncontrolled regime to controlled regime after 12 weeks of intervention.

--2 Merge tables Demographics, Chronic Conditions and Text Messages
select a.*,b.*,c.* into [kyuan].[f] from [dbo].[Demographics] a
inner join
[dbo].[ChronicConditions] b on a.contactid = b.tri_patientid
inner join
[dbo].[Text] c on  a.contactid = c.tri_contactId
--Merge tables demographics, chronic conditions and text messags by each ID 
select * from [kyuan].[f]
inner join
(select [contactid], max([TextSentDate]) as latestDate
from [kyuan].[f] group by [contactid]) SubMax on [kyuan].[f].TextSentDate = SubMax.latestDate and [kyuan].[f].contactid = SubMax.contactid
--Obtain the final dataset such that we have 1 row per Id by chossing latest date when text was sent

select * from [kyuan].[f]


