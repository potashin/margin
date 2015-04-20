# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

AssetType.create([
	                 {name: 'SECURITY', description: 'Ценная бумага'},
	                 {name: 'FX', description: 'Валюта'}
                 ])

OrderPriceType.create([
	                      {name: 'MARKET', description: 'Рыночная'},
	                      {name: 'LIMIT', description: 'Ограниченная'}
                      ])
OrderStateType.create([
	                      {name: 'o', description: 'Активные'},
	                      {name: 'w', description: 'Снятые'},
	                      {name: 'm', description: 'Исполненные'}
                      ])
ClientType.create([
	                  {name: 'KSUR', description: 'Клиент со стандартным уровнем риска'},
	                  {name: 'KPUR', description: 'Клиент с повышенным уровнем риска'},
	                  {name: 'KOUR', description: 'Клиент с особым уровнем риска'}
                  ])


Asset.create([
	             {name: 'GAZP', description: 'ГАЗПРОМ', asset_type_id: 1},
	             {name: 'USD', asset_type_id: 2},
	             {name: 'RUB', asset_type_id: 2},
	             {name: 'LKOH', description: 'ЛУКОЙЛ' , asset_type_id: 1},
	             {name: 'VTB', description: 'ВТБ' , asset_type_id: 1},
	             {name: 'EUR', asset_type_id: 2},
	             {name: 'KZT', asset_type_id: 2},
             ])

ItemStatusType.create([
	                      {name: 'REQUIREMENT',description: 'Требования'},
	                      {name: 'OBLIGATION',description: 'Обязательства'},
	                      {name: 'BALANCE',description: 'Остаток'},
                      ])

OrderStatusType.create([
	                       {name: 'BUY',description: 'Покупка'},
	                       {name: 'SELL',description: 'Продажа'},
                       ])

AssetPrice.create([
	                  {asset_id: 1, payment_instrument_id: 3, last: 140},
	                  {asset_id: 6, payment_instrument_id: 3, last: 75},
	                  {asset_id: 2, payment_instrument_id: 3, last: 65},
	                  {asset_id: 4, payment_instrument_id: 3, last: 2849},
	                  {asset_id: 3, payment_instrument_id: 3, last: 1},
	                  {asset_id: 2, payment_instrument_id: 6, last: 0.9},
	                  {asset_id: 6, payment_instrument_id: 2, last: 1.2},
                  ])

AssetDiscount.create([
	                     {asset_id: 3, client_type_id: 1, d0_plus: 0, d0_minus: 0, dx_plus: 0, dx_minus: 0},
	                     {asset_id: 2, client_type_id: 1, d0_plus: 0.1, d0_minus: 0.15, dx_plus: 0.05, dx_minus: 0.05},
	                     {asset_id: 6, client_type_id: 1, d0_plus: 0.15, d0_minus: 0.20, dx_plus: 0.08, dx_minus: 0.08},
	                     {asset_id: 1, client_type_id: 1, d0_plus: 0.3, d0_minus: 0.35, dx_plus: 0.16, dx_minus: 0.16}
                     ])
Item.create([
	            {client_id: 1, asset_id: 2, item_status_type_id: 3, quantity: 100},
	            {client_id: 1, asset_id: 1, item_status_type_id: 3, quantity: 10}
            ])

Order.create([
	             {client_id: 1, asset_id: 6, payment_instrument_id: 2, order_status_type_id: 1, price: 1.10, quantity: 5, order_state_type_id: 1, order_price_type_id: 2},
	             {client_id: 1, asset_id: 1, payment_instrument_id: 3, order_status_type_id: 2, price: 90, quantity: 10, order_state_type_id: 1, order_price_type_id: 2},
	             {client_id: 1, asset_id: 1, payment_instrument_id: 3, order_status_type_id: 1, price: 110, quantity: 4, order_state_type_id: 1, order_price_type_id: 2}
             ])

# снять все заявки
# если плохо, то закрываем короткие позиции
# если все равно плохо, то продаем активы
# таблица порядков ликвидации
# сколько чего продать

# сколько может купить/продать

# клиринг требований/обязательств