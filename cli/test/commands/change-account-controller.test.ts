import {expect, test} from '@oclif/test'

describe('change-account-controller', () => {
  test
  .stdout()
  .command(['change-account-controller'])
  .it('runs hello', ctx => {
    expect(ctx.stdout).to.contain('hello world')
  })

  test
  .stdout()
  .command(['change-account-controller', '--name', 'jeff'])
  .it('runs hello --name jeff', ctx => {
    expect(ctx.stdout).to.contain('hello jeff')
  })
})
