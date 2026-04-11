@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Order 015'
define root view entity ZI_LOG_ORD_015
  as select from ztlog_ord_015 as FreightOrder 
  composition [0..*] of ZI_LOG_ITM_015 as _Items
{
  key order_id as OrderId,
  customer_name as CustomerName,
  status as Status,
  
  case status
    when 'N' then 2 // Yellow (New)
    when 'I' then 1 // Red (Wait/In Transit)
    when 'D' then 3 // Green (Delivered)
    else 0
  end as StatusCriticality,

  @Semantics.quantity.unitOfMeasure: 'WeightUnit'
  total_weight as TotalWeight,
  weight_unit as WeightUnit,
  created_at as CreatedAt,
  
  /* NEW: Flagging the Total ETag Field */
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  
  _Items
}
