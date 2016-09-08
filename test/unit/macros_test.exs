defmodule ConfexMacrosTest do
  use ExUnit.Case
  doctest Confex

  defmodule TestModule do
    use Confex,
      otp_app: :confex,
      overriden_var: {:system, "OVER_VAR"}

    defp validate_config(config) do
      if is_nil(config) do
        throw "Something went wrong"
      end

      config
    end
  end

  defmodule TestModuleWithoutOTP do
    use Confex,
      overriden_var: {:system, "OVER_VAR"}

    defp validate_config(config) do
      if is_nil(config) do
        throw "Something went wrong"
      end

      config
    end
  end

  setup do
    System.delete_env("TESTENV")
    System.delete_env("TESTINTENV")
    System.delete_env("OVER_VAR")

    Application.put_env(:confex, ConfexMacrosTest.TestModule, [
      foo: "bar",
      num: 1,
      nix: {:system, :integer, "TESTINTENV"},
      tix: {:system, :integer, "TESTINTENV", 300},
      baz: {:system, "TESTENV"},
      biz: {:system, "TESTENV", "default_val"},
      mex: {:system, :string, "TESTENV"},
      tox: {:system, :string, "TESTENV", "default_val"},
    ])

    :ok
  end

  test "different definition types" do
    assert [overriden_var: nil,
            foo: "bar",
            num: 1,
            nix: nil,
            tix: 300,
            baz: nil,
            biz: "default_val",
            mex: nil,
            tox: "default_val"] = TestModule.config

    System.put_env("TESTENV", "other_val")
    System.put_env("TESTINTENV", "600")
    System.put_env("OVER_VAR", "readme")

    assert [overriden_var: "readme",
            foo: "bar",
            num: 1,
            nix: 600,
            tix: 600,
            baz: "other_val",
            biz: "other_val",
            mex: "other_val",
            tox: "other_val"] = TestModule.config
  end

  test "module without OTP app" do
    assert [overriden_var: nil] = TestModuleWithoutOTP.config

    System.put_env("OVER_VAR", "readme")

    assert [overriden_var: "readme"] = TestModuleWithoutOTP.config
  end
end