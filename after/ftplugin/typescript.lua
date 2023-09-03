local function LookupNodeModule(fname)
  local basePath = vim.fn.finddir('node_modules',
                                  vim.fn.expand('%:p:h') .. ';' ..
                                    vim.fn.getcwd()) .. '/' .. fname
  local indexFileJs = basePath .. 'index.js'
  local indexFileTs = basePath .. 'index.ts'
  local packageFile = basePath .. 'package.json'

  if vim.fn.filereadable(packageFile) == 1 then
    local package = vim.fn.json_decode(vim.fn.readfile(packageFile))

    if vim.fn.has_key(package, 'module') then
      return basePath .. '/' .. package.module
    end

    if vim.fn.has_key(package, 'main') then
      return basePath .. '/' .. package.main
    end
  elseif vim.fn.filereadable(indexFileTs) == 1 then
    return indexFileTs
  elseif vim.fn.filereadable(indexFileJs) == 1 then
    return indexFileJs
  end

  return basePath
end

-- Improve Node Editing
vim.opt.isfname:append{ '@-@' } -- some node_modules are namespaced with an @
vim.opt_local.suffixesadd:append{ '.js', '.json', '.jsx', '.ts', '.tsx' }
vim.opt_local.includeexpr = LookupNodeModule(vim.v.fname)
