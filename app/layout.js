import './globals.css'
import Link from 'next/link'
import { Package, ShoppingCart, Archive, BarChart3, DollarSign, PieChart, Banknote, Truck, Calendar, Settings, List } from 'lucide-react'

export const metadata = {
  title: 'Crazy Clothes',
  description: 'Sistema de inventario y ventas',
}

export default function RootLayout({ children }) {
  return (
    <html lang="es">
      <body className="min-h-screen bg-stone-50 text-stone-900 antialiased">
        <div className="flex min-h-screen">
          {/* Sidebar */}
          <aside className="w-64 bg-white border-r border-stone-200 flex flex-col">
            <div className="p-6 border-b border-stone-200">
              <h1 className="text-xl font-semibold tracking-tight text-stone-900">
                Crazy Clothes
              </h1>
            </div>
            <nav className="flex-1 p-4 space-y-1">
              <NavLink href="/inventario" icon={Archive}>Inventario</NavLink>
              <NavLink href="/ventas" icon={ShoppingCart}>Ventas</NavLink>
              <NavLink href="/compras" icon={Package}>Compras</NavLink>
              <NavLink href="/pedidos" icon={Truck}>Pedidos</NavLink>
              <NavLink href="/comisiones" icon={DollarSign}>Comisiones</NavLink>
              <NavLink href="/capital" icon={PieChart}>Capital</NavLink>
              <NavLink href="/deudas" icon={Banknote}>Deudas</NavLink>
              <NavLink href="/cierres" icon={Calendar}>Cierres</NavLink>
              <NavLink href="/reportes" icon={BarChart3}>Reportes</NavLink>

              <div className="pt-4 mt-4 border-t border-stone-200">
                <NavLink href="/config" icon={Settings}>Configuración</NavLink>
                <NavLink href="/listas" icon={List}>Listas</NavLink>
              </div>
            </nav>
            <div className="p-4 border-t border-stone-200 text-xs text-stone-500">
              v1.0 · {new Date().getFullYear()}
            </div>
          </aside>

          {/* Main */}
          <main className="flex-1 overflow-auto">
            <div className="max-w-7xl mx-auto p-8">
              {children}
            </div>
          </main>
        </div>
      </body>
    </html>
  )
}

function NavLink({ href, icon: Icon, children }) {
  return (
    <Link
      href={href}
      className="flex items-center gap-3 px-4 py-2.5 rounded-lg text-stone-700 hover:bg-stone-100 hover:text-stone-900 transition-colors duration-150"
    >
      <Icon className="w-5 h-5 text-stone-500" />
      <span className="text-sm font-medium">{children}</span>
    </Link>
  )
}
