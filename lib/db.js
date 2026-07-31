import mysql from 'mysql2/promise'

/**
 * Pool único por proceso. En dev, Next recarga los módulos en cada cambio,
 * así que el pool se guarda en globalThis o se abren decenas de conexiones
 * hasta agotar max_connections de RDS.
 */
let pool
export function db() {
  if (!pool) {
    pool = globalThis.__ccPool ?? mysql.createPool({
      host: process.env.DB_HOST,
      port: Number(process.env.DB_PORT ?? 3306),
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      // RDS con require_secure_transport=ON rechaza conexiones sin TLS.
      ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: true } : undefined,
      waitForConnections: true,
      connectionLimit: 8,
      // DECIMAL como string: si se convierte a float, el dinero pierde
      // centavos en el redondeo. Se convierte a número solo al presentar.
      decimalNumbers: false,
      dateStrings: ['DATE'],
      charset: 'utf8mb4',
      characterEncoding: 'utf8mb4',
    })
    if (process.env.NODE_ENV !== 'production') globalThis.__ccPool = pool
  }
  return pool
}

export async function q(sql, params = []) {
  const [rows] = await db().execute(sql, params)
  return rows
}

/** Varias sentencias que deben pasar o fallar juntas (venta + movimientos). */
export async function tx(fn) {
  const conn = await db().getConnection()
  try {
    await conn.beginTransaction()
    const out = await fn(async (sql, params = []) => {
      const [rows] = await conn.execute(sql, params)
      return rows
    })
    await conn.commit()
    return out
  } catch (e) {
    await conn.rollback()
    throw e
  } finally {
    conn.release()
  }
}
