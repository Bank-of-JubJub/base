import {expect, test} from '@oclif/test'

describe('process-pending-transfers', () => {
  test
  .stdout()
  .command(['process-pending-transfers'])
  .it('runs hello', ctx => {
    expect(ctx.stdout).to.contain('hello world')
  })

  test
  .stdout()
  .command(['process-pending-transfers', '--name', 'jeff'])
  .it('runs hello --name jeff', ctx => {
    expect(ctx.stdout).to.contain('hello jeff')
  })
})
