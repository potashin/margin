class DbBuild < ActiveRecord::Migration
	def change

# Table creation :

		execute "CREATE TABLE asset_types (id VARCHAR(20) NOT NULL PRIMARY KEY, description TEXT);"
		execute "CREATE TABLE client_types (id VARCHAR(10) NOT NULL PRIMARY KEY, description TEXT, is_available BOOL DEFAULT 1);"
		execute "CREATE TABLE assets (
              id VARCHAR(20) NOT NULL PRIMARY KEY
            , description TEXT
            , is_liquid BOOL DEFAULT 1
            , asset_type_id VARCHAR(10)
            , FOREIGN KEY(asset_type_id) REFERENCES asset_types(id)
		        , CHECK( NOT(is_liquid = 0 AND asset_type_id = 'FX') ));"

		execute "CREATE TABLE asset_discounts (
                  asset_id VARCHAR(20) NOT NULL
                , client_type_id VARCHAR(10) NOT NULL
                , DoPLUS FLOAT
                , DoMINUS FLOAT
                , DxPLUS FLOAT
                , DxMINUS FLOAT
                , PRIMARY KEY (asset_id, client_type_id)
                , FOREIGN KEY(asset_id) REFERENCES assets(id)
                , FOREIGN KEY(client_type_id) REFERENCES client_types(id));"
		execute "CREATE TABLE asset_prices (
                  asset_id VARCHAR(20) NOT NULL
                , payment_instrument_id VARCHAR(20) NOT NULL
                , last FLOAT
                , PRIMARY KEY (asset_id, payment_instrument_id)
                , FOREIGN KEY(asset_id) REFERENCES assets(id)
                , FOREIGN KEY(payment_instrument_id) REFERENCES assets(id));"

		execute "CREATE TABLE status_types (
                  id VARCHAR(20) NOT NULL PRIMARY KEY
                , description TEXT
		            , for_id VARCHAR(10)
								, CHECK( for_id IN ('ORDER', 'ITEM') ));"

		execute "CREATE TABLE order_price_types (
                  id VARCHAR(20) NOT NULL PRIMARY KEY
                , description TEXT);"

		execute "CREATE TABLE order_state_types (
                  id VARCHAR(20) NOT NULL PRIMARY KEY
                , description TEXT);"


		execute "CREATE TABLE clients (
                  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
                , login VARCHAR(15) UNIQUE NOT NULL
                , name VARCHAR(50)
                , surname VARCHAR(50)
                , email VARCHAR(50) NOT NULL
                , encrypted_password VARCHAR(100) NOT NULL
                , client_type_id VARCHAR(100) DEFAULT 'KSUR'
                , FOREIGN KEY(client_type_id) REFERENCES client_types(id));"

		execute "CREATE TABLE items (
                  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
                , client_id INT NOT NULL
                , asset_id VARCHAR(20) NOT NULL
                , payment_instrument_id VARCHAR(20)
                , status_type_id VARCHAR(20) NOT NULL
								, price FLOAT
                , quantity INT NOT NULL
                , FOREIGN KEY(client_id) REFERENCES client(id)
                , FOREIGN KEY(status_type_id) REFERENCES status_types(id)
                , FOREIGN KEY(asset_id) REFERENCES assets(id)
                , FOREIGN KEY(payment_instrument_id) REFERENCES assets(id)
								, CHECK( status_type_id NOT IN('BUY','SELL') )
						);"

		execute "CREATE TABLE orders (
                  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
                , client_id INT NOT NULL
                , asset_id VARCHAR(20) NOT NULL
                , payment_instrument_id VARCHAR(20)
                , status_type_id VARCHAR(20) NOT NULL
                , price FLOAT
                , quantity INT NOT NULL
								, order_state_type_id VARCHAR(1) DEFAULT 'o'
								, order_price_type_id VARCHAR(20)
                , FOREIGN KEY(client_id) REFERENCES client(id)
								, FOREIGN KEY(order_price_type_id) REFERENCES order_price_types(id)
		            , FOREIGN KEY(order_state_type_id) REFERENCES order_state_types(id)
                , FOREIGN KEY(status_type_id) REFERENCES status_types(id)
                , FOREIGN KEY(asset_id) REFERENCES assets(id)
                , FOREIGN KEY(payment_instrument_id) REFERENCES assets(id)
								, CHECK( status_type_id IN('BUY','SELL') )
                , CHECK( (order_price_type_id = 'MARKET' AND payment_instrument_id IS NULL AND price IS NULL) OR (order_price_type_id = 'LIMIT' AND payment_instrument_id IS NOT NULL AND price IS NOT NULL) ) );"

# Views creation :

		execute "CREATE VIEW price_spreads AS
							SELECT 	o.client_id,
								o.asset_id,
								MIN(COALESCE(MIN(CASE WHEN o.status_type_id = 'BUY'  THEN o.price*p.last END),ap.last*apc.last+1),ap.last*apc.last)  AS Pplus,
								MAX(COALESCE(MAX(CASE WHEN o.status_type_id = 'SELL' THEN o.price*p.last END),0),ap.last*apc.last)  AS Pminus
							FROM orders o
							LEFT JOIN asset_prices p ON  p.asset_id = o.payment_instrument_id AND p.payment_instrument_id = 'RUB'
							LEFT JOIN asset_prices ap ON ap.asset_id = o.asset_id
							LEFT JOIN asset_prices apc ON ap.payment_instrument_id = apc.asset_id AND apc.payment_instrument_id = 'RUB'
							GROUP BY o.client_id, o.asset_id"

		execute   "CREATE VIEW portfolio_items_totals AS
								SELECT i.client_id
									, i.asset_id
									,COALESCE(SUM((CASE WHEN i.status_type_id = 'OBLIGATION' THEN -1 ELSE 1 END)*i.quantity*ap.last*cur.last), 0) AS total_price
									,COALESCE(SUM((CASE WHEN i.status_type_id = 'OBLIGATION' THEN -1 ELSE 1 END)*i.quantity), 0) AS total_quantity
								FROM items i
								LEFT JOIN asset_prices ap ON i.asset_id = ap.asset_id
								LEFT JOIN asset_prices cur ON cur.asset_id = ap.payment_instrument_id
								GROUP BY i.client_id, i.asset_id"

		execute "CREATE VIEW item_per_collection_list AS
							SELECT 	o.client_id,
								o.asset_id,
								COALESCE(CASE WHEN is_liquid OR a.asset_type_id = 'FX' THEN o.ka_quantity END, 0) AS ka_quantity,
								COALESCE(CASE WHEN is_liquid OR a.asset_type_id = 'FX' THEN o.kl_quantity END, 0) AS kl_quantity,
								o.flag,
								CASE 	WHEN (o.price IS NULL AND o.payment_instrument_id IS NULL
									  OR (o.status_type_id = 'SELL' AND o.price*p.last < ap.last*apc.last)
									  OR (o.status_type_id = 'BUY' AND o.price*p.last > ap.last*apc.last))
						      THEN ap.last*apc.last
									ELSE o.price*p.last
								END AS price,
								status_type_id,
								COALESCE(CASE WHEN is_liquid = 0 AND a.asset_type_id = 'SECURITY' THEN kl_quantity END, 0) AS not_liquid
							FROM (
								SELECT 	client_id,
									asset_id,
									payment_instrument_id,
									CASE WHEN status_type_id = 'BUY' THEN quantity END AS ka_quantity,
									CASE WHEN status_type_id = 'SELL' THEN quantity END AS kl_quantity,
									status_type_id,
									price,
									asset_id AS asset_liquid_check,
									0 AS flag
								FROM orders
								UNION ALL
								SELECT 	client_id,
									payment_instrument_id,
									payment_instrument_id,
									CASE WHEN status_type_id = 'SELL' THEN COALESCE(price,1)*quantity END,
									CASE WHEN status_type_id = 'BUY' THEN COALESCE(price,1)*quantity END,
									status_type_id,
									CASE WHEN price IS NULL THEN NULL ELSE 1 END,
									asset_id,
									1 AS flag
								FROM orders o
							) o
							JOIN assets a ON a.id = o.asset_liquid_check
							LEFT JOIN asset_prices p ON  p.asset_id = o.payment_instrument_id AND p.payment_instrument_id = 'RUB'
							LEFT JOIN asset_prices ap ON ap.asset_id = o.asset_id
							LEFT JOIN asset_prices apc ON ap.payment_instrument_id = apc.asset_id AND apc.payment_instrument_id = 'RUB'
							WHERE o.flag OR (o.flag = 0 AND (a.is_liquid OR a.asset_type_id = 'FX'))"

		execute "CREATE VIEW item_per_collection_total AS
							SELECT 	ipc.client_id,
								ipc.asset_id,
								SUM((CASE WHEN ipc.flag THEN ipc.price ELSE 1 END)*ipc.ka_quantity) AS ka_quantity,
								SUM((CASE WHEN ipc.flag THEN ipc.price ELSE 1 END)*ipc.kl_quantity) AS kl_quantity,
								SUM(ipc.price*ipc.ka_quantity) AS ka_total,
								SUM(ipc.price*ipc.kl_quantity) AS kl_total,
								SUM(ipc.not_liquid) AS not_liquid_total,
								SUM(CASE WHEN (status_type_id = 'BUY' and flag = 1) THEN ipc.price*ipc.kl_quantity*MAX(ps.Pplus*(1 - ad.DoPLUS) - ipc.price,0) ELSE 0 END) AS additional_risk_minus,
								SUM(CASE WHEN (status_type_id = 'SELL' and flag = 1) THEN ipc.price*ipc.ka_quantity*MAX(ipc.price - ps.Pminus*(1 + ad.DoMINUS),0) ELSE 0 END) AS additional_risk_plus,
								ps.Pplus,
								ps.Pminus,
								ad.DoPLUS,
								ad.DoMINUS,
								ad.DxPLUS,
								ad.DxMINUS
							FROM item_per_collection_list ipc
							JOIN clients c ON c.id = ipc.client_id
							JOIN asset_discounts ad ON ipc.asset_id = ad.asset_id AND c.client_type_id = ad.client_type_id
							LEFT JOIN price_spreads ps ON ps.asset_id = ipc.asset_id
							GROUP BY	ipc.client_id,
								ipc.asset_id,
								ps.Pplus,
								ps.Pminus,
								ad.DoPLUS,
								ad.DoMINUS"
		execute "CREATE VIEW marginal_prices AS
							SELECT 	pit.client_id,
								pit.asset_id,
								COALESCE(pit.total_price, 0) AS total,
								(COALESCE(pit.total_quantity, 0) + COALESCE(qpc.ka_quantity,0) - COALESCE(qpc.not_liquid_total,0))*COALESCE(qpc.Pplus,0) AS S_plus,
								(COALESCE(pit.total_quantity, 0) - COALESCE(qpc.kl_quantity,0) - COALESCE(qpc.not_liquid_total,0))*COALESCE(qpc.Pminus,0) AS S_minus,
								COALESCE(ka_total,0) AS ka_total,
								COALESCE(kl_total,0)  AS kl_total,
								qpc.additional_risk_plus,
								qpc.additional_risk_minus,
								qpc.DoPLUS,
								qpc.DoMINUS,
								qpc.DxPLUS,
								qpc.DxMINUS
							FROM (
								SELECT *
								FROM portfolio_items_totals
								UNION
								SELECT client_id, asset_id, 0, 0
								FROM orders o
								WHERE asset_id NOT IN(SELECT asset_id FROM portfolio_items_totals  WHERE client_id = o.client_id)
							) pit
							JOIN assets a ON a.id = pit.asset_id
							LEFT JOIN item_per_collection_total qpc ON pit.client_id = qpc.client_id AND pit.asset_id = qpc.asset_id
							WHERE a.is_liquid OR a.asset_type_id = 'FX'"

		execute "CREATE VIEW portfolios AS
							SELECT 	c.id  AS client_id
							      , SUM(mp.total) AS price
							      , SUM(MAX(MAX(-mp.total*mp.DoMINUS,0),  MAX(mp.total*mp.DoPLUS,0))) AS m_initial
							      , SUM(MAX(MAX(-mp.total*mp.DxMINUS,0),  MAX(mp.total*mp.DxPLUS,0))) AS m_minimum
								, SUM(MAX(
									mp.total - mp.S_plus + mp.ka_total + MAX(mp.S_plus*mp.DoPLUS,-mp.S_plus*mp.DoMINUS) + mp.additional_risk_plus,
									mp.total - mp.S_minus - mp.kl_total + MAX(mp.S_minus*mp.DoPLUS,-mp.S_minus*mp.DoMINUS) + mp.additional_risk_plus)) AS m_order
							FROM clients c
							LEFT JOIN marginal_prices mp ON c.id = mp.client_id
							GROUP BY mp.client_id"
	end
end
