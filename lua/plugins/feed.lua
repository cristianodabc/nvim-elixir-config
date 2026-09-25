return {
  {
    "neo451/feed.nvim",
    cmd = "Feed",
    keys = {
      { "<leader>nf", "<cmd>Feed index<cr>", desc = "Open feed list" },
      { "<leader>ns", "<cmd>Feed search<cr>", desc = "Search/filter feeds" },
      { "<leader>nu", "<cmd>Feed update<cr>", desc = "Update all feeds" },
      { "<leader>nl", "<cmd>Feed list<cr>", desc = "List feed sources" },
    },
    opts = {
      feeds = {
        tech = {
          { "https://hnrss.org/frontpage", name = "Hacker News" },
          { "https://lobste.rs/rss", name = "Lobsters" },
          { "https://www.theverge.com/rss/index.xml", name = "The Verge" },
          { "https://feeds.arstechnica.com/arstechnica/index", name = "Ars Technica" },
          { "https://simonwillison.net/atom/everything/", name = "Simon Willison" },
        },

        elixir = {
          { "https://elixir-lang.org/atom.xml", name = "Elixir Blog" },
          { "https://dashbit.co/feed", name = "Dashbit" },
          { "https://fly.io/blog/feed.xml", name = "Fly.io" },
          { "https://underjord.io/feed.xml", name = "Underjord" },
          { "https://www.erlang.org/news.xml", name = "Erlang News" },
          { "https://www.erlang.org/blog.xml", name = "Erlang Blog" },
          { "https://www.erlang-solutions.com/blog/feed/", name = "Erlang Solutions" },
        },

        security = {
          { "https://github.com/mirego/elixir-security-advisories/commits/main.atom", name = "Hex Advisories" },
          { "https://github.com/erlang/otp/releases.atom", name = "OTP Releases" },
          { "https://github.com/elixir-lang/elixir/releases.atom", name = "Elixir Releases" },
        },

        fp = {
          { "https://www.tweag.io/rss.xml", name = "Tweag" },
        },

        papers = {
          { "https://rss.arxiv.org/rss/cs.PL", name = "arXiv cs.PL" },
          { "https://rss.arxiv.org/rss/cs.DC", name = "arXiv cs.DC" },
        },
      },

      options = {
        index = {
          wo = {
            number = true,
            relativenumber = true,
            statuscolumn = "",
          },
        },
      },
    },
  },
}
