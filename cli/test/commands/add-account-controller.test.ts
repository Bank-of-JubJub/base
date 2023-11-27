import {expect, test} from '@oclif/test'

describe('add-account-controller', () => {
  test
  .stdout()
  .command(['add-account-controller'])
  .it('runs hello', ctx => {
    expect(ctx.stdout).to.contain('hello world')
  })

  test
  .stdout()
  .command(['add-account-controller', '--name', 'jeff'])
  .it('runs hello --name jeff', ctx => {
    expect(ctx.stdout).to.contain('hello jeff')
  })
})
