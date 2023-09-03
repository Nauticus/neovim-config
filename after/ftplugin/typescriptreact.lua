local function tsrIncludeexpr(fname)
    vim.print("LookupNodeModule: " .. fname)
    return fname
end

vim.opt_local.suffixesadd:append({ ".js", ".json", ".jsx", ".ts", ".tsx" })
vim.opt_local.includeexpr = tsrIncludeexpr(vim.v.fname)
