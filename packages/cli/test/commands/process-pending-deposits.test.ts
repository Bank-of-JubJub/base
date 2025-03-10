import {expect, test} from '@oclif/test'

describe('process-pending-deposits', () => {
  test
  .stdout()
  .command(['process-pending-deposits'])
  .it('runs hello', ctx => {
    expect(ctx.stdout).to.contain('hello world')
  })

  test
  .stdout()
  .command(['process-pending-deposits', '--name', 'jeff'])
  .it('runs hello --name jeff', ctx => {
    expect(ctx.stdout).to.contain('hello jeff')
  })
})
