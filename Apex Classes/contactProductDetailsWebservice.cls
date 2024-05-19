@RestResource(urlMapping='/contactUUID/*')
global class contactProductDetailsWebservice {
    @HttpGet
    global static contactProductDetailsController.productDetailsWrapper getContactsByUUID() {
        contactProductDetailsController.productDetailsWrapper productDetailData = new contactProductDetailsController.productDetailsWrapper();
        RestRequest req = RestContext.request;
        String uuid = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        //Check to handle blank request
        if(!String.isEmpty(uuid)){
            // Query for contact based on the UUID
            List<Contact> contactRecordList = [SELECT Id,Product__c,Product__r.Name,Home_Country__c FROM Contact WHERE UUID__c = :uuid limit 1];
            //Check if contact available or not 
            if(contactRecordList.size()>0){
                Contact contactRecord = contactRecordList[0];
                //Common method is called to retrieve the product details based on contact record
                productDetailData=contactProductDetailsController.getProductDetails(contactRecord);
            }
            else{
                productDetailData.message= uuid+' contact not available.';
            }
        }
        else{
            productDetailData.message='UUID not available.';
        }
        
        return productDetailData;
    }
    
}