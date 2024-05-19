# N26
Solution for Case Study N26 Interview

For preparing the data model of the given case study, I have utilized all standard objects and enabled Multi-Currency in my org to handle multiple currencies simultaneously. I have considered Standard, Black, and Metal as three different Products, which I am storing in the standard Product object. To store different types of charges in different countries, I have used the standard PriceBook object. I created a custom Country picklist to store different types of charges for various countries. Since the standard PriceBookEntry has a lookup relationship with both PriceBook and Product, I have used this object to store all the charges related to the Product and PriceBook for different countries.

**First Task:**


As per the task, I have created an LWC component to use on the Case record page. Since Case has a standard lookup relationship with Contact, I have created two custom fields on Contact to store Product and Country details. Based on the Case record ID, I retrieved the Contact record and its related Product and Country. As per the data model, I have all the charges and required information on PriceBook Entry. I fetched all active PriceBook entries based on Contact's Product and Country data to show on the LWC Component.


**Second Task:**


In this case, there was a requirement to fetch product details based on UUID, which is unique for each Contact. I have created a custom field on the Contact named UUID. Since this needs to be fetched from an external system I created it as a unique externalId field. I have created a webservice class and an HTTP GET method in it. In this method, I am reading the UUID, and based on the UUID, I am fetching Contact's Country and Product information. As per the data model, I have all the charges and required information on PriceBook Entry. I fetched all active PriceBook entries based on Contact's Product and Country data to send as a response in the webservice class. Considering the limitations of Salesforce, I am handling query limits and heap size limits before retrieving data from Salesforce.


**Data Model Overview**

**Objects Utilized**- Product2, PriceBook2, PriceBookEntry, Contact, Case.

**Custom Fields Object wise:**


**Contact-** 

 
  Home_Country__c (Picklist-Used Global Value Set for Country list)
  
  Product__c (Lookup-with Standard Object Product2)
  
  UUID__c (Text-As an external ID field this needs to be unique per contact and will be fetched by external systems.)

  **PriceBook2-**

  
  Country__c (Picklist-Used Global Value Set for Country list)

  

**PriceBookEntry-**

  
  Category_Value__c (Text-To store values which are not currency value)
  




