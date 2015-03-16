# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

=begin

AssetType.create([{id: 'SECURITY'}, {id: 'FX'}])
ClientType.create([{id: 'KSUR'}, {id: 'KPUR'}, {id: 'KOUR'}])

Asset.create([
	             {id: 'GAZP', asset_type_id: 'SECURITY'},
	             {id: 'USD' , asset_type_id: 'FX'},
	             {id: 'RUB' , asset_type_id: 'FX'},
                 {id: 'LKOH', asset_type_id: 'SECURITY'},
                {id: 'VTB', asset_type_id: 'SECURITY'},
	             {id: 'EUR' , asset_type_id: 'FX'},
	             {id: 'KZT' , description: '' , asset_type_id: 'FX', is_liquid: false},
             ])

StatusType.create([{id: 'REQUIREMENT',description: 'Требования'}
								, {id: 'OBLIGATION',description: 'Обязательства'}
								, {id: 'BALANCE',description: 'Остаток'}
								, {id: 'BUY',description: 'Покупка'}
								, {id: 'SELL'},description: 'Продажа'])

AssetPrice.create([{asset_id: 'GAZP', payment_instrument_id: 'RUB', last: 140},
                   {asset_id: 'EUR', payment_instrument_id: 'RUB', last: 75},
                   {asset_id: 'USD', payment_instrument_id: 'RUB', last: 65},
					{asset_id: 'LKOH', payment_instrument_id: 'RUB', last: 2849},
										{asset_id: 'RUB', payment_instrument_id: 'RUB', last: 1},
				])

AssetDiscount.create([{asset_id: 'RUB', client_type_id: 'KSUR', DoPLUS: 0, DoMINUS: 0, DxPLUS: 0, DxMINUS: 0},
                      {asset_id: 'USD', client_type_id: 'KSUR', DoPLUS: 0.1, DoMINUS: 0.15, DxPLUS: 0.05, DxMINUS: 0.05},
                      {asset_id: 'EUR', client_type_id: 'KSUR', DoPLUS: 0.15, DoMINUS: 0.20, DxPLUS: 0.08, DxMINUS: 0.08},
                      {asset_id: 'GAZP', client_type_id: 'KSUR', DoPLUS: 0.3, DoMINUS: 0.35, DxPLUS: 0.16, DxMINUS: 0.16}])


Item.create([{id: 1, client_id: 1, asset_id: 'USD', payment_instrument_id: 'RUB', status_type_id: 'BALANCE', quantity: 100},
             {id: 2, client_id: 1, asset_id: 'GAZP', payment_instrument_id: 'RUB', status_type_id: 'BALANCE', quantity: 10}])
=end