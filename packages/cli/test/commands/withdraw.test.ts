import {expect, test} from '@oclif/test'

describe('withdraw', () => {
  test
  .stdout()
  .command(['withdraw'])
  .it('runs hello', ctx => {
    expect(ctx.stdout).to.contain('hello world')
  })

  test
  .stdout()
  .command(['withdraw', '--name', 'jeff'])
  .it('runs hello --name jeff', ctx => {
    expect(ctx.stdout).to.contain('hello jeff')
  })
})
