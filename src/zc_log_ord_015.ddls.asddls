@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for Order 015'
@Metadata.allowExtensions: true
define root view entity ZC_LOG_ORD_015
  provider contract transactional_query
  as projection on ZI_LOG_ORD_015
{
  key OrderId,
  CustomerName,
  Status,
  
  /* We just project the field directly from the ZI view now! */
  StatusCriticality,
@Semantics.quantity.unitOfMeasure: 'WeightUnit'
  TotalWeight,
  
  WeightUnit,
 
  CreatedAt,
  
  /* Associations */
  _Items : redirected to composition child ZC_LOG_ITM_015
}
