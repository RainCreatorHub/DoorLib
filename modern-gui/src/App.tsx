import { useEffect, useState } from 'react'

function ThemeToggle() {
  const [isDark, setIsDark] = useState<boolean>(() => {
    if (typeof window === 'undefined') return false;
    return (
      localStorage.getItem('theme') === 'dark' ||
      (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)
    );
  });

  useEffect(() => {
    const root = document.documentElement;
    if (isDark) {
      root.classList.add('dark');
      localStorage.setItem('theme', 'dark');
    } else {
      root.classList.remove('dark');
      localStorage.setItem('theme', 'light');
    }
  }, [isDark]);

  return (
    <button
      onClick={() => setIsDark((v) => !v)}
      className="inline-flex items-center gap-2 rounded-xl border border-zinc-300 bg-white/80 px-3 py-2 text-sm font-medium text-zinc-800 shadow-sm backdrop-blur hover:bg-white dark:border-zinc-700 dark:bg-zinc-800/80 dark:text-zinc-100 dark:hover:bg-zinc-800"
      aria-label="Alternar tema"
    >
      <span className="i-lucide-sun h-4 w-4 dark:hidden" aria-hidden="true" />
      <span className="i-lucide-moon hidden h-4 w-4 dark:inline" aria-hidden="true" />
      <span>{isDark ? 'Escuro' : 'Claro'}</span>
    </button>
  );
}

function Navbar() {
  return (
    <header className="sticky top-0 z-40 w-full border-b border-zinc-200 bg-white/70 backdrop-blur dark:border-zinc-800 dark:bg-zinc-900/60">
      <div className="container mx-auto flex h-16 items-center justify-between px-4">
        <a className="flex items-center gap-2 text-xl font-bold tracking-tight" href="#">
          <span className="h-6 w-6 rounded bg-gradient-to-br from-indigo-500 to-fuchsia-500" />
          <span className="text-zinc-900 dark:text-zinc-100">Modern GUI</span>
        </a>
        <nav className="hidden gap-6 text-sm font-medium text-zinc-600 md:flex dark:text-zinc-300">
          <a className="hover:text-zinc-900 dark:hover:text-white" href="#features">Recursos</a>
          <a className="hover:text-zinc-900 dark:hover:text-white" href="#pricing">Preços</a>
          <a className="hover:text-zinc-900 dark:hover:text-white" href="#faq">FAQ</a>
        </nav>
        <div className="flex items-center gap-3">
          <ThemeToggle />
          <a
            className="rounded-lg bg-zinc-900 px-3 py-2 text-sm font-semibold text-white shadow hover:bg-zinc-800 dark:bg-white dark:text-zinc-900 dark:hover:bg-zinc-100"
            href="#"
          >
            Entrar
          </a>
        </div>
      </div>
    </header>
  );
}

function Hero() {
  return (
    <section className="relative isolate overflow-hidden">
      <div className="pointer-events-none absolute inset-0 -z-10 bg-gradient-to-b from-zinc-50 to-white dark:from-zinc-950 dark:to-zinc-900" />
      <div className="container mx-auto grid min-h-[72vh] items-center gap-10 px-4 py-24 lg:grid-cols-2">
        <div className="flex flex-col items-start gap-6">
          <span className="inline-flex items-center rounded-full border border-indigo-200 bg-indigo-50 px-3 py-1 text-xs font-medium text-indigo-700 dark:border-indigo-900/50 dark:bg-indigo-950/60 dark:text-indigo-300">
            Novo • UI moderna pronta para produção
          </span>
          <h1 className="text-balance text-4xl font-bold tracking-tight text-zinc-900 sm:text-5xl md:text-6xl dark:text-zinc-50">
            Construa interfaces bonitas com velocidade
          </h1>
          <p className="max-w-prose text-pretty text-lg text-zinc-600 dark:text-zinc-300">
            Comece com uma base sólida de componentes e estilos. Tema claro/escuro, responsivo e acessível.
          </p>
          <div className="flex flex-wrap gap-3">
            <a className="rounded-lg bg-indigo-600 px-4 py-2.5 text-sm font-semibold text-white shadow hover:bg-indigo-500" href="#features">
              Começar agora
            </a>
            <a className="rounded-lg border border-zinc-300 px-4 py-2.5 text-sm font-semibold text-zinc-800 hover:bg-zinc-50 dark:border-zinc-700 dark:text-zinc-100 dark:hover:bg-zinc-800/60" href="#">
              Ver código
            </a>
          </div>
        </div>
        <div className="relative">
          <div className="aspect-[4/3] w-full overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-xl dark:border-zinc-800 dark:bg-zinc-900">
            <div className="h-full w-full bg-gradient-to-br from-indigo-500/20 via-fuchsia-500/20 to-cyan-400/20" />
          </div>
          <div className="absolute -bottom-6 -left-6 -z-10 h-40 w-40 rounded-full bg-indigo-500/20 blur-3xl"></div>
          <div className="absolute -right-6 -top-6 -z-10 h-40 w-40 rounded-full bg-fuchsia-500/20 blur-3xl"></div>
        </div>
      </div>
    </section>
  );
}

function Features() {
  const features = [
    { title: 'Tema dinâmico', desc: 'Claro/Escuro com um clique.' },
    { title: 'Responsivo', desc: 'Design que se adapta a qualquer tela.' },
    { title: 'Acessível', desc: 'Melhores práticas de acessibilidade incluídas.' },
    { title: 'Developer-first', desc: 'Stack moderno com Vite + React + TS.' },
  ];
  return (
    <section id="features" className="border-t border-zinc-200 py-20 dark:border-zinc-800">
      <div className="container mx-auto px-4">
        <h2 className="mb-8 text-center text-3xl font-bold tracking-tight text-zinc-900 dark:text-zinc-50">
          Recursos
        </h2>
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
          {features.map((f) => (
            <div key={f.title} className="rounded-2xl border border-zinc-200 bg-white p-6 shadow-sm transition hover:shadow-md dark:border-zinc-800 dark:bg-zinc-900">
              <div className="mb-3 h-10 w-10 rounded-lg bg-gradient-to-br from-indigo-500 to-fuchsia-500" />
              <h3 className="text-lg font-semibold text-zinc-900 dark:text-zinc-100">{f.title}</h3>
              <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-400">{f.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

export default function App() {
  return (
    <div className="min-h-screen bg-white text-zinc-900 antialiased dark:bg-zinc-950 dark:text-zinc-100">
      <Navbar />
      <main>
        <Hero />
        <Features />
      </main>
      <footer className="border-t border-zinc-200 py-10 text-center text-sm text-zinc-500 dark:border-zinc-800 dark:text-zinc-400">
        Feito com React + Tailwind.
      </footer>
    </div>
  );
}
