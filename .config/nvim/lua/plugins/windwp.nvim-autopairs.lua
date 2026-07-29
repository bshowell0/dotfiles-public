return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  config = function()
    require('nvim-autopairs').setup({ check_ts = true }) -- optional TS checks
    local ok, cmp = pcall(require, 'cmp')
    if ok then
      local cmp_ap = require('nvim-autopairs.completion.cmp')
      cmp.event:on('confirm_done', cmp_ap.on_confirm_done())
    end
  end,
}
