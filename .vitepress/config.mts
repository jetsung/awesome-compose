import { defineConfig } from 'vitepress'
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

// Function to generate sidebar items dynamically
function getSidebarItems() {
  const rootDir = path.resolve(__dirname, '..')
  const items: { text: string; link: string }[] = []

  const files = fs.readdirSync(rootDir)

  files.forEach(file => {
    const filePath = path.join(rootDir, file)

    // Skip if not a directory or is hidden
    if (!fs.statSync(filePath).isDirectory() || file.startsWith('.')) {
      return
    }

    // Skip node_modules and .vitepress
    if (file === 'node_modules' || file === '.vitepress') {
      return
    }

    // Check if README.md exists in the directory
    if (fs.existsSync(path.join(filePath, 'README.md'))) {
      items.push({
        text: file,
        link: `/${file}/`
      })
    }
  })

  // Sort items alphabetically
  return items.sort((a, b) => a.text.localeCompare(b.text))
}

// Function to generate rewrites dynamically
function getRewrites() {
  const rootDir = path.resolve(__dirname, '..')
  const rewrites: Record<string, string> = {}

  // Root README
  if (fs.existsSync(path.join(rootDir, 'README.md'))) {
    rewrites['README.md'] = 'index.md'
  }

  const files = fs.readdirSync(rootDir)

  files.forEach(file => {
    const filePath = path.join(rootDir, file)

    // Skip if not a directory or is hidden
    if (!fs.statSync(filePath).isDirectory() || file.startsWith('.')) {
      return
    }

    // Skip node_modules and .vitepress
    if (file === 'node_modules' || file === '.vitepress') {
      return
    }

    // Check if README.md exists in the directory
    if (fs.existsSync(path.join(filePath, 'README.md'))) {
      rewrites[`${file}/README.md`] = `${file}/index.md`
    }
  })

  return rewrites
}

export default defineConfig({
  title: "Awesome Compose",
  description: "Docker Compose Self-hosted Services",
  cleanUrls: true,

  // Map README.md to index.md for root and all subdirectories
  rewrites: getRewrites(),

  themeConfig: {
    nav: [
      { text: 'Home', link: '/' },
    ],

    sidebar: [
      {
        text: 'Projects',
        items: getSidebarItems()
      }
    ],

    socialLinks: [
      { icon: 'gitea', link: 'https://git.asfd.cn/jetsung/awesome-compose' },
      { icon: 'github', link: 'https://github.com/jetsung/awesome-compose' },
    ],

    search: {
      provider: 'local'
    },

    footer: {
      message: 'Released under the Apache-2.0 License.',
      copyright: 'Copyright © 2024 iDEV SIG'
    }
  },

  ignoreDeadLinks: true
})
