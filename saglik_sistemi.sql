-- sağlık hizmeti adında yeni bir veri tabanı oluşturma.
create database [sağlık hizmeti];

-- sağlık hizmeti adlı veritabanı seçilmesi.
use [sağlık hizmeti];

-- tablodaki kolonlar hakkında genel bilgilerin bulunması.
select TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'saglik_hizmeti';

-- veritabanındaki veriler görüntülenir.
select * from dbo.saglik_hizmeti;

-- 1. SORGU tabloda toplam veri sayısı bulunur. 
select COUNT(*) as [toplam veri sayısı] from saglik_hizmeti;

-- 2.SORGU  en yaşlı hastanın bulunması.
select MAX(Age) as [maximum yaş] from saglik_hizmeti; 

-- 3. SORGU ortalama hasta yaşının bulunması
select avg(Age) as [ortalama yaş] from saglik_hizmeti;

-- 4. SORGU hastaların yaşlarına göre maksimumdan minimuma hesaplanması.
select Age, COUNT(Age) as toplam
from saglik_hizmeti
group by Age
order by Age desc;

-- 5. SORGU azalan yaşa göre hastaneye yatırılan toplam hasta bazında Maksimum Hasta Sayısının hesaplanması.
select Age,  COUNT(Age) as toplam
from saglik_hizmeti
group by Age
order by toplam desc, Age desc;

-- 6. SORGU alfabetik sıraya göre adların sıralanması.
select Name as [alfabetik sıra]
from saglik_hizmeti
order by Name;

--  7. SORGU erkek ve kadın hasta sayısının bulunması.
select 
	count(case Gender when 'Female' then 1 end) as [Kadın Sayısı],
	count(case Gender when 'Male' then 1 end) as [Erkek Sayısı]
from saglik_hizmeti

-- 8. SORGU obezite olan hasta sayısının bulunması.
select COUNT(*) as [obezite hasta sayısı]
from saglik_hizmeti
where Medical_Condition = 'Obesity'

-- 9. SORGU en yaşlı hasta detaylarının bulunması.
select top 1 *
from saglik_hizmeti
order by Age desc


-- 10. SORGU tüm hastalar içindeki obezite oranını bulunması.
select (cast (COUNT(case Medical_Condition when 'Obesity' then 1 end) as float) / COUNT(Medical_Condition)) * 100 as [yüzde diyabet oranı]
from saglik_hizmeti

-- 11. SORGU tüm hastalar içindeki AB+ oranını bulunması.
select (CAST(COUNT(case Blood_Type when 'AB+' then 1 end) as float) / COUNT(*)) * 100 as [yüzde AB+ kan grubu oranı]
from saglik_hizmeti

-- 12. SORGU hastaların kan grubuna göre dağılımının bulunması.
select Blood_Type,  COUNT(*) as sayısı
from saglik_hizmeti
group by Blood_Type


-- 13. SORGU kadın erkek sayısı hesaplanması.
select Gender, COUNT(*)
from saglik_hizmeti
group by Gender 


-- 12. SORGU hastaların tıbbi durumuna göre toplam sayısının bulunması maksimum hasta sayısına göre sıralanması.
select  Medical_Condition ,COUNT(*) as [toplam hasta sayısı]
from saglik_hizmeti
group by Medical_Condition
order by  [toplam hasta sayısı] desc;

-- 13. SORGU hastaneye yatan hastaların tercih etiği sigortaların bulunması.
select Insurance_Provider , COUNT(*) as [toplam]
from saglik_hizmeti
group by Insurance_Provider 
order by toplam desc

-- 14. SORGU en çok tercih edilen hastanelerin bulunması.
select hospital, COUNT(*) as [toplam]
from saglik_hizmeti
group by Hospital
order by toplam desc;

-- 15. SORGU ortalama fatura tutarının tıbbi duruma göre belirlenmesi.
select Medical_Condition, round(avg(Billing_Amount), 2) as [ortalama tutar]
from saglik_hizmeti
group by Medical_Condition
order by [ortalama tutar] desc;

--16. SORGU hastanede geçirilen gün sayısı ve hastanedeki hastaların fatura toplamlarının bulunması
select Name, Medical_Condition, Hospital ,
DATEDIFF(DAY,Date_of_Admission ,Discharge_Date) as [kalınan gün sayısı],
sum(round(Billing_Amount, 2))  over(partition by hospital order by hospital desc) as [fatura toplamı]
from saglik_hizmeti

--17. SORGU hastaya ait kalınan gün sayısı ve faturanın bulunması
select Medical_Condition, Name, Hospital , DATEDIFF(day, Date_of_Admission, Discharge_Date) as [kalınan gün sayısı], ROUND(Billing_Amount, 2) as fatura
from saglik_hizmeti


-- 18. SORGU test sonucu Normal çıkan hastların medikal duruma ve hastaneye göre gruplanıp hastanede kaldıkları gün sayısının hesaplanması.
select Name, Medical_Condition, Hospital, DATEDIFF(DAY, Date_of_Admission, Discharge_Date) as [geçen gün sayısı]
from saglik_hizmeti
where Test_Results = 'Normal' -- alternatif : Test_Result LIKE 'Normal' 
order by Hospital, Medical_Condition


-- 19. SORGU 20 ve 40 yaş arası hastaların kan gruplarına göre gruplanıp toplamının bulunması.
select age ,Blood_Type, COUNT(*) as [kişi sayısı]
from saglik_hizmeti
where Age between 20 and 40 
group by Blood_Type, age
order by Age

-- 20. SORGU test sonucu ve yaşa göre gruplama yapılması
select Test_Results,age , COUNT(*) as toplam
from saglik_hizmeti
group by Test_Results , Age
order by toplam desc;

-- 21. SORGU genel kan alıcı ve verici grupların toplam sayısının bulunması.
select sum(case Blood_Type when 'AB+' THEN 1 END) AS [genel kan alıcı],
		SUM(case Blood_Type when 'O-' THEN 1 END) as [genel kan verici]
from saglik_hizmeti


--23. SORGU  2022 ve 2023 yıllarında hastaneye kabul edilen hasta sayılarının bulunması.
select Hospital, COUNT(*) as toplam, YEAR(Date_of_Admission) as yıl
from saglik_hizmeti
where YEAR(Date_of_Admission) in (2023, 2022)
group by Hospital, YEAR(Date_of_Admission)
order by toplam desc

--24. SORGU sigorta sağlayıcılar için max, min, ortalama fatura tutarları bulunması.
select Insurance_Provider, round(AVG(Billing_Amount), 2) as ortalama, round(MIN(Billing_Amount), 2) as minimum, round(MAX(Billing_Amount), 2) as maximum
from saglik_hizmeti
group by Insurance_Provider

-- 25. SORGU test sonuçlarına göre yeni bir kolon oluşturarak risk gruplarına ayrılması.
select Name, (case Test_Results when 'Inconclusive' then 'Orta Risk' when 'Abnormal' then 'Yüksek Risk' else 'Düşük Risk' end) as [risk durumu], Doctor
from saglik_hizmeti

-- 26. SORGU yıllara göre kabul edilen hasta sayısının bulunması
select YEAR(Date_of_Admission) as yıl , COUNT(*) as toplam
from saglik_hizmeti
group by YEAR(Date_of_Admission)
order by toplam desc

-- 27. SORGU en çok hasta kabul edilen günün bulunması
select DATENAME(weekday, Date_of_Admission)  as [gün] , COUNT(*) as toplam
from saglik_hizmeti
group by DATENAME(weekday, Date_of_Admission)
order by toplam desc

-- 28. SORGU yaş gruplarına göre toplam hasta sayısının bulunması
select(case when Age < 20 then 'Genç' when Age between 20 and 40 then 'Yetişkin' when Age> 40 then 'Orta Yaş' else 'Yaşlı' end) as [yaş grubu],
COUNT(*) as toplam
from saglik_hizmeti
group by (case when Age < 20 then 'Genç' when Age between 20 and 40 then 'Yetişkin' when Age> 40 then 'Orta Yaş' else 'Yaşlı' end)
order by toplam desc

-- 29. SORGU kaç çeşit test_result oluğunun bulunması.
select Test_Results                                                
from saglik_hizmeti
group by Test_Results

-- 30. SORGU normal , anormal ve belirsiz test sonuçlarının yüzdeliklerinin bulunması.
select test_results, cast(count(*) * 100.0 / (select count(*) from saglik_hizmeti) as decimal (4,2)) as [yüzdelik dilim]
from saglik_hizmeti
group by test_results;

-- 31. SORGU Name kolonun harflerinin küçük harfe dönüştürülmesi.
select LOWER(Name)
from saglik_hizmeti


-- 32. SORGU başvuru tipine göre toplam hasta sayısının bulunması.
select Admission_Type, COUNT(*) as [başvuru tipi]
from saglik_hizmeti
group by Admission_Type

-- 33. SORGU doctora göre hasta sayısı.
select Doctor, COUNT(*) as toplam
from saglik_hizmeti
group by Doctor
order by toplam desc


-- 34. SORGU başvuru durumuna göre yüzdelik hesaplanması.
select Admission_Type ,cast(COUNT(*) * 100.0 / (select COUNT(*) from saglik_hizmeti) as decimal(4,2)) as [yüzdelik dilim]
from saglik_hizmeti
group by Admission_Type


-- 35. SORGU ilaç yüzdelik hesaplanması.
select Medication , cast(COUNT(*) * 100.0 / (select COUNT(*) from saglik_hizmeti) as decimal (4,2)) as [yüzdelik dilim]
from saglik_hizmeti
group by Medication


-- 36. SORGU cinsiyete göre fatura tutarlarının belirlenmesi.
select  Gender, round(SUM(Billing_Amount), 2)  as [fatura toplamı]
from saglik_hizmeti
group by Gender


-- 37. SORGU doktora göre toplam fatura tutarının hesaplanması.
select Doctor, round(SUM(Billing_Amount), 2) as fatura 
from saglik_hizmeti
group by Doctor
order by fatura desc



-- 38. SORGU  kan grubu ve cinsiyet arasındaki ilişkinin bulunması.
select Gender, Blood_Type, COUNT(*) as toplam
from saglik_hizmeti
group by Gender, Blood_Type
order by Gender , toplam


-- 39. SORGU cinsiyetlerin hangİ hastalıktan daha fazla etkilendiğinin bulunması.
select Medical_Condition, Gender, cast(COUNT(*) * 100.0 / SUM(COUNT(*)) over (partition by medical_condition) as decimal(4,2)) as yüzdelik
from saglik_hizmeti
group by Medical_Condition, Gender


-- 40. SORGU başvuru tipi ve ilac arasındaki ilişkinin bulunması.
select Admission_Type, Medication, COUNT(*) as toplam
from saglik_hizmeti
group by Admission_Type, Medication
order by Admission_Type, toplam desc


-- 41. SORGU  toplamda kaç oda olduğunun bulunması.
select COUNT( distinct Room_Number)
from saglik_hizmeti


-- 42. SORGU en çok tercih edilen odaların sıralanması.
select  Room_Number , COUNT(*) as toplam
from saglik_hizmeti
group by Room_Number
order by toplam desc

-- 43. SORGU odalarda kalan hastaların yüzdeliklerinin bulunması.
select Room_Number, cast (COUNT(*) * 100.0 /
(select count(distinct Room_Number) from saglik_hizmeti) as decimal(4,2)) as [yüzdelik dilim]
from saglik_hizmeti
group by Room_Number
order by [yüzdelik dilim] desc

-- 44. SORGU  kaç benzersiz isim olduğunun bulunması.
select COUNT(distinct Name)
from saglik_hizmeti

-- 45. SORGU hastaneye birden fazla başvurmuş hasta sayısının bulunması.
select Name, COUNT(*) as [toplam başvuru sayısı]
from saglik_hizmeti
group by Name
having COUNT(*) > 1
order by COUNT(*)  desc


--46. SORGU yaşa göre gruplayıp toplam hasanın bulunması
select FLOOR(Age / 10) *  10 as [gruplanmış yaş],  COUNT(*) toplam
from saglik_hizmeti
group by FLOOR(Age / 10)
order by toplam desc

--46. SORGU yaşa göre gruplayıp toplam hasanın bulunması (alternatif sorgu)
select (case when Age between 0 and 9 then '0-9'
        when Age between 10 and 19 then '10-19'
         when Age between 20 and 29 then '20-29'
         when Age between 30 and 39 then '30-39'
         when Age between 40 and 49 then '40-49'
         when Age between 50 and 59 then '50-59'
         when Age between 60 and 69 then '60-69'
         when Age between 70 and 79 then '70-79'
         when Age between 80 and 89 then '80-89'
         when Age between 90 and 99 then '90-99'
		 end ) as [gruplanmış yaş],
		 COUNT(*) toplam
from saglik_hizmeti
group by (case when Age between 0 and 9 then '0-9'
        when Age between 10 and 19 then '10-19'
         when Age between 20 and 29 then '20-29'
         when Age between 30 and 39 then '30-39'
         when Age between 40 and 49 then '40-49'
         when Age between 50 and 59 then '50-59'
         when Age between 60 and 69 then '60-69'
         when Age between 70 and 79 then '70-79'
         when Age between 80 and 89 then '80-89'
         when Age between 90 and 99 then '90-99'
		 end)
order by toplam

-- 47. SORGU yıllara göre doktorun toplam kabul ettiği hata sayısı.
select Doctor, YEAR(Date_of_Admission) as yıl , count(*) as toplam
from saglik_hizmeti 
group by Doctor, YEAR(Date_of_Admission)
order by toplam desc

-- 48. SORGU Her gün için o günkü toplam kabul miktarının ve bir önceki tarihe göre değişen miktarı görüntülenmesi.
select Date_of_Admission, COUNT(*) as toplam_kabül,
COUNT(*) - lag(COUNT(*)) over (order by date_of_Admission) as gün_farkı
from saglik_hizmeti
group by Date_of_Admission

