@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Item 015'
define view entity ZI_LOG_ITM_015
  as select from ztlog_itm_015 as Item
  association to parent ZI_LOG_ORD_015 as _Order on $projection.OrderId = _Order.OrderId
{
  key order_id as OrderId,
  key item_id as ItemId,
  material_name as MaterialName,
  
  @Semantics.quantity.unitOfMeasure: 'Unit'
  quantity as Quantity,
  unit as Unit,
  
  _Order
}
