global class contactProductDetailsController {
    global static productDetailsWrapper productDetailData = new productDetailsWrapper();
    
    //Method used by LWC to pass Case recordId and retreive related products.
    @AuraEnabled(cacheable=true)
    public static productDetailsWrapper fetchProductdetails(Id recordId) {
        try {
            List<PricebookEntry> finalproductDetails = new List<PricebookEntry>();
            // Fetch contact details based on the Case record ID
            Case caserecord=[select id,contactid from Case where id=:recordId];
            if(caserecord.contactid!=null){
                Contact contactRecord =[SELECT Id,Product__c,Product__r.Name,Home_Country__c FROM Contact WHERE Id = :caserecord.contactid limit 1];
                productDetailData=getProductDetails(contactRecord);
            }
            else{
                productDetailData.message='No contact available.';
            }
            return productDetailData;
        } catch (Exception e) {
            //to handle exception and throw aura controlled error message
            throw new AuraHandledException('Error fetching product details: ' + e.getMessage());
        }
    }
    //Method to return product details based on Contact record.
    public static productDetailsWrapper getProductDetails(Contact contactRecord){
        List<PricebookEntry> pricebookEntriesList = new List<PricebookEntry>();
        List<EntryList> pricebookList = new List<EntryList>();
        if(contactRecord.Product__c==null){
                productDetailData.message='Product and Country needs to be associated with the contact to get product details.';
            }
            else{
                productDetailData.productName=contactRecord.Product__r.Name;
            }
            if(contactRecord.Home_Country__c==null){
                productDetailData.message='Product and Country needs to be associated with the contact to get product details.';
            }
            else{
                productDetailData.country=getPicklistLabel(contactRecord.Home_Country__c);
            }
            if(contactRecord.Home_Country__c!=null && contactRecord.Product__c!=null){
                pricebookEntriesList=[select id,Name,Product2.Name,Product2Id,ToLabel(Pricebook2.Country__c),Pricebook2.Description,  Pricebook2.Name,UnitPrice, CurrencyIsoCode, Category_Value__c,UseStandardPrice from PricebookEntry where Pricebook2.IsActive =true and Product2Id=:contactRecord.Product__c and Pricebook2.Country__c=:contactRecord.Home_Country__c order by Pricebook2.Description ];
        		if(pricebookEntriesList.size()>0){
                    for(PricebookEntry pricebook:pricebookEntriesList){
                        EntryList singleEntry = new EntryList();
                        singleEntry.pricebookName=pricebook.Pricebook2.Description;
                        if(String.isEmpty(pricebook.Category_Value__c)){
                            singleEntry.pricebookValue=pricebook.CurrencyIsoCode+' '+pricebook.UnitPrice;
                        }
                        else{
                            singleEntry.pricebookValue=pricebook.Category_Value__c;
                        }
                        pricebookList.add(singleEntry);
                    }
                    productDetailData.priceBookList=pricebookList;
                    productDetailData.message=pricebookEntriesList.size()+' pricebook entry available.';
                }
                else{
                    productDetailData.message='No pricebook entry available.';
                }
            }
        return productDetailData;
    }
    //Method to get Country picklist Label based on API value
    public static String getPicklistLabel(String picklistValue) {
        Schema.SObjectType contactType = Schema.getGlobalDescribe().get('Contact');
        Schema.DescribeSObjectResult contactDescribe = contactType.getDescribe();
        Schema.DescribeFieldResult fieldDescribe = contactDescribe.fields.getMap().get('Home_Country__c').getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistValues) {
            if (entry.getValue() == picklistValue) {
                return entry.getLabel();
            }
        }
        return 'No matching label found';
    }
    //Wrapper Class to use for both LWC and Response in Webservice Class
    global class productDetailsWrapper{
        @AuraEnabled public String productName;
        @AuraEnabled public String country;
        @AuraEnabled public List<EntryList> priceBookList;
        @AuraEnabled public String message;
    }
    global class EntryList{
        @AuraEnabled public String pricebookName;
        @AuraEnabled public String pricebookValue; 
    }
}