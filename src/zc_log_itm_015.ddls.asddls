@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for Item 015'
@Metadata.allowExtensions: true
define view entity ZC_LOG_ITM_015
  as projection on ZI_LOG_ITM_015
{
  key OrderId,
  key ItemId,
      MaterialName,

      @Semantics.quantity.unitOfMeasure: 'Unit'
      Quantity,

      Unit,

      /* Associations */
      _Order : redirected to parent ZC_LOG_ORD_015
}
