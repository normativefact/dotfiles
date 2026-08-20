return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	lazy = true,
	ft = "markdown",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		legacy_commands = false,
		workspaces = {
			{
				name = "PKM",
				path = "~/notes",
			},
		},

		ui = { enable = false },

		completion = {
			blink = true,
			min_chars = 2,
		},

		daily_notes = {
			folder = "dailies",
			date_format = "%d-%m-%Y",
			template = "Daily.md",
		},

		note_id_func = function(title)
			if title ~= nil and title ~= "" then
				-- Option A: Keeps exact spaces & casing -> "Causal Analysis.md"
				return title

				-- Option B (if you prefer clean kebab-case): "causal-analysis.md"
				-- return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
			else
				-- Fallback only if you create a note with no title at all
				return tostring(os.date("%d-%m-%Y"))
			end
		end,

		-- 2. Force the filesystem path to match the ID directly
		note_path_func = function(spec)
			local path = spec.dir / tostring(spec.id)
			return path:with_suffix(".md")
		end,

		templates = {
			folder = "Templates",
			date_format = "%d-%m-%Y",
			time_format = "%H:%M",
			substitutions = {},
			customizations = {
				Daily = {
					notes_subdir = "dailies",
				},
				Default = {
					notes_subdir = "10_Fleeting",
				},
				Literature = {
					notes_subdir = "20_Literature",
				},
				Learning = {
					notes_subdir = "30_Permanent",
				},
				Zettel = {
					notes_subdir = "30_Permanent",
				},
				MOCs = {
					notes_subdir = "40_MOCs",
				},
				Reflection = {
					notes_subdir = "50_Reflections",
				},
			},
		},

	},
}
