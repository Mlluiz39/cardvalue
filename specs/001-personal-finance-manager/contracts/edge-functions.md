# Edge Function Contracts

## 1. generate-insights

**Trigger**: Cron (weekly Sun 20:00 BRT) + on-demand via `supabase.functions.invoke()`

### Request
```json
{
  "userId": "uuid",       // from JWT (on-demand) or explicit (cron)
  "forceRefresh": false   // bypass cache
}
```

### Response (Edge Function)
```json
{
  "insights": [
    {
      "type": "spending_anomaly",
      "title": "Alimentação fora aumentou 35%",
      "message": "Você gastou R$ 850 em alimentação fora este mês, contra R$ 630 no mês passado.",
      "severity": "warning",
      "data": { "category": "Alimentação", "previousTotal": 630, "currentTotal": 850, "increasePct": 35 }
    },
    {
      "type": "limit_warning",
      "title": "Cartão Nubank接近 do limite",
      "message": "Você já usou 82% do limite do seu cartão Nubank (R$ 4.100 de R$ 5.000).",
      "severity": "critical",
      "data": { "cardId": "uuid", "cardName": "Nubank", "usedPercent": 82 }
    }
  ],
  "generatedAt": "2026-05-18T20:00:00Z"
}
```

### Implementation Notes
- Uses GPT-4o-mini for natural language generation
- Queries Supabase directly (via service_role for cron, user JWT for on-demand)
- Rate-limited: max 1 invocation per user per 6 hours (on-demand)
- Cron variant runs all active users in batch

---

## 2. reconcile-invoice

**Trigger**: On-demand when user imports/attaches an invoice

### Request
```json
{
  "cardId": "uuid",
  "invoiceCycleId": "uuid",
  "lineItems": [
    {
      "description": "Amazon *MKTPLACE",
      "amount": 149.90,
      "date": "2026-04-15"
    },
    {
      "description": "UBER *TRIP",
      "amount": 23.50,
      "date": "2026-04-16"
    }
  ]
}
```

### Response
```json
{
  "reportId": "uuid",
  "summary": {
    "totalItems": 10,
    "matched": 7,
    "unmatched": 2,
    "discrepancies": 1
  },
  "items": [
    {
      "id": "uuid",
      "invoiceDescription": "Amazon *MKTPLACE",
      "invoiceAmount": 149.90,
      "matchStatus": "matched",
      "matchedPurchaseId": "uuid",
      "registeredAmount": 149.90,
      "difference": 0
    },
    {
      "id": "uuid",
      "invoiceDescription": "DESPESA DESCONHECIDA",
      "invoiceAmount": 50.00,
      "matchStatus": "unmatched",
      "matchedPurchaseId": null,
      "registeredAmount": null,
      "difference": null
    },
    {
      "id": "uuid",
      "invoiceDescription": "RESTAURANTE X",
      "invoiceAmount": 250.00,
      "matchStatus": "discrepancy",
      "matchedPurchaseId": "uuid",
      "registeredAmount": 200.00,
      "difference": 50.00
    }
  ]
}
```

### Algorithm
1. Normalize descriptions (lowercase, strip special chars, common merchant variants)
2. For each line item, find matching purchase on same card with:
   - Approximate date match (±5 days)
   - Value match within tolerance (±R$5 or ±5%)
   - Description similarity (Jaccard or Levenshtein)
3. If one match found → "matched"
4. If no match found → "unmatched"
5. If multiple matches or value/date mismatch → "discrepancy"

---

## 3. process-receipt-ocr

**Trigger**: On-demand when user uploads receipt photo/PDF

### Request
```
POST multipart/form-data
- file: (binary, image or PDF)
- type: "receipt_photo" | "invoice_pdf"
```

### Response
```json
{
  "success": true,
  "extractedData": {
    "merchant": "Supermercado ABC",
    "amount": 157.80,
    "date": "2026-05-15",
    "category": "Mercado",
    "confidence": 0.87
  },
  "rawText": "SUPERMERCADO ABC\nCNPJ: 00.000.000/0001-00\n15/05/2026 14:32\n\nARROZ TIO JOÃO ... 12,90\nFEIJÃO ... 8,50\n...\nTOTAL R$ 157,80",
  "processingTime": 1200
}
```

### Implementation Notes
- On-device: Google ML Kit for image receipt (fl_client)
- Server-side (fallback): Edge Function with Vision API for complex PDFs
- Structured extraction: regex patterns for Brazilian receipt format
- Category suggestion: match merchant name against known patterns

---

## 4. classify-transaction

**Trigger**: On-demand when user is adding a transaction

### Request
```json
{
  "merchant": "Uber",
  "amount": 23.50,
  "description": "Uber *TRIP 15/05",
  "recentTransactions": [
    { "merchant": "Uber", "category": "Transporte" },
    { "merchant": "Rappi", "category": "Alimentação" }
  ]
}
```

### Response
```json
{
  "suggestedCategoryId": "uuid",
  "suggestedCategoryName": "Transporte",
  "confidence": 0.92,
  "alternatives": [
    { "categoryId": "uuid", "name": "Lazer", "confidence": 0.05 }
  ]
}
```

### Implementation Notes
- First pass: rule-based matching against user's history (merchant name patterns)
- Second pass: GPT-4o-mini for ambiguous cases
- Return top suggestion with confidence score
